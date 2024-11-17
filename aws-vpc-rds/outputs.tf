output "rds-db-endpoint" {
  value = aws_db_instance.rds_postgres.endpoint
}
