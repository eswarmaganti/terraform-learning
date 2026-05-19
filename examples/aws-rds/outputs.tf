output "rds-endpoint" {
  value = aws_db_instance.rds-postgres.address
}
output "rds-password" {
  value = random_password.rds_password.result
}
