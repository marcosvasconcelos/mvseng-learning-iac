variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "aws_profile" {
  type    = string
  default = "mvseng-learning-tf"
}

variable "aws_access_key" {
  type      = string
  sensitive = true
  default   = null
}

variable "aws_secret_key" {
  type      = string
  sensitive = true
  default   = null
}
