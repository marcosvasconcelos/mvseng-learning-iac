provider "aws" {
  region     = var.aws_region
  profile    = var.aws_profile
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { Name = "my-vpc-dev" }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public" {
  count = 2

  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index + 1}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "my-public-subnet-${count.index + 1}-dev"
    AZ   = data.aws_availability_zones.available.names[count.index]
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "my-internet-gateway-dev" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "public_association" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "http_sg" {
  name        = "http-sg"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "http-sg"
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2-instance-sg"
  description = "Security group for EC2 instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-instance-sg"
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

resource "aws_lb" "main" {
  name               = "my-alb-dev"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public[*].id

  enable_deletion_protection = false

  tags = {
    Name        = "my-alb-dev"
    Environment = "dev"
  }
}

resource "aws_lb_target_group" "web_servers" {
  name     = "web-servers-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200"
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  target_type = "instance"

  tags = {
    Name        = "web-servers-tg"
    Environment = "dev"
  }
}

resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_servers.arn
  }

  tags = {
    Name = "web-listener"
  }
}

module "aws_instance" {
  source = "../../modules/aws/ec2_instance"
  count  = 2

  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = "t2.micro"
  instance_name      = "web-server-${count.index + 1}"
  vpc_id             = aws_vpc.main.id
  subnet_id          = aws_subnet.public[count.index].id
  security_group_ids = [aws_security_group.ec2_sg.id, aws_security_group.http_sg.id]
}

resource "aws_lb_target_group_attachment" "web_servers" {
  count = length(module.aws_instance)

  target_group_arn = aws_lb_target_group.web_servers.arn
  target_id        = module.aws_instance[count.index].instance_id
  port             = 80
}

output "web_server_ips" {
  value = module.aws_instance.*.public_ip
}

output "load_balancer_dns" {
  value = aws_lb.main.dns_name
}

output "availability_zones" {
  value = data.aws_availability_zones.available.names
}

output "subnet_info" {
  value = {
    for i, subnet in aws_subnet.public :
    subnet.tags.Name => {
      id                = subnet.id
      cidr_block        = subnet.cidr_block
      availability_zone = subnet.availability_zone
    }
  }
}