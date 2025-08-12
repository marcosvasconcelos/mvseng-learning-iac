# Arquivo: modules/aws/s3_bucket/main.tf

resource "aws_s3_bucket" "main" {
  bucket = var.bucket_name
  acl    = "private"

  tags = {
    Name        = var.bucket_name
    Environment = "dev"
  }
}