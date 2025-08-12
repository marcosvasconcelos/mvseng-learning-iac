output "public_ip" {
  value = aws_instance.main.public_ip
}

output "public_dns" {
  value = aws_instance.main.public_dns
}

output "instance_id" {
  value = aws_instance.main.id
}

output "availability_zone" {
  value = aws_instance.main.availability_zone
}