# Arquivo: providers/aws/variables.tf
variable "aws_region" {
  type        = string
  description = "The AWS region where resources will be created."
  default     = "us-east-1"
}

variable "aws_profile" {
  type        = string
  description = "AWS Profile name from ~/.aws/credentials"
  default     = "mvseng-learning-tf"
}

variable "aws_access_key" {
  type        = string
  description = "AWS Access Key ID"
  sensitive   = true
  default     = null
}

variable "aws_secret_key" {
  type        = string
  description = "AWS Secret Access Key"
  sensitive   = true
  default     = null
}
