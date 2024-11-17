output "rds-endpoint" {
  value = aws_db_instance.rds-postgres.address
}
