resource "aws_db_instance" "rds-postgres" {
  allocated_storage   = var.rds_size
  engine              = var.rds_engine
  instance_class      = var.rds_instance_class
  skip_final_snapshot = true
  username            = "postgres"
  password            = "postgres"
  publicly_accessible = true
}
