variable "ami_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "instance_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}