variable "rds_size" {
  default     = 10
  description = "the size of rds instance storage"
  type        = number
}
variable "rds_engine" {
  default     = "postgres"
  description = "the rds engine to be installed in rds instance"
  type        = string
}

variable "rds_instance_class" {
  default     = "db.t3.micro"
  description = "the instance type of db"
}
