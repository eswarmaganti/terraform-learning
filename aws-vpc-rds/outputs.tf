output "rds-db-endpoint" {
  value = aws_db_instance.rds_postgres.endpoint
}
output "bation-public-ip" {
  value = aws_instance.bation_instance.public_ip
}
