variable "ami_id" {
  type        = string
  description = "The AMI ID to use for the EC2 instance."
}

variable "instance_type" {
  type        = string
  description = "The instance type for the EC2 instance."
  default     = "t2.micro"
  # Only 'instance_type' has a default value; other variables must be provided for flexibility and to avoid accidental resource misconfiguration.
}

variable "instance_name" {
  type        = string
  description = "The name tag for the EC2 instance."
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID to launch the instance into."
}

variable "subnet_id" {
  type        = string
  description = "The subnet ID to launch the instance into."
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of security group IDs to assign to the instance."
}