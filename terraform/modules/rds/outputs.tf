
output "db_name" {
  value = aws_db_instance.this.db_name
}

output "db_instance_identifier" {
  value = aws_db_instance.this.identifier
}
output "db_endpoint" {
  value = aws_db_instance.this.address
}