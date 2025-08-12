# Create multiple EC2 instances of type y.z in the specified subnet.
resource "aws_instance" "main" {
    ami           = var.ami_id
    instance_type = var.instance_type
    subnet_id     = var.subnet_id
    
    # Associate the SSH key (replace "my-key" with your key name)
    key_name      = "my-key" 

    # Associate the security groups passed as a parameter
    vpc_security_group_ids = var.security_group_ids

    user_data = <<EOF
                            #!/bin/bash
                            sudo yum update -y
                            sudo amazon-linux-extras install nginx1 -y
                            sudo systemctl start nginx
                            sudo systemctl enable nginx
                            echo "<h1>Hello World from ${var.instance_name}!</h1>" | sudo tee /usr/share/nginx/html/index.html
                            EOF

    tags = {
        Name        = var.instance_name
        Environment = "dev"
    }
}