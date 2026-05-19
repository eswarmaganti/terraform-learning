variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "the cidr for vpc"
}
variable "subnets_public_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  description = "the cidr block for public subnets"
}

variable "subnets_private_cidr" {
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
  description = "The cidr block for private subnets"
}

variable "rds_storage" {
  type    = number
  default = 10

}

variable "rds_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "subnets_private_azs" {
  default = ["us-east-1c", "us-east-1d"]
  type    = list(string)
}

variable "subnets_public_azs" {
  default = ["us-east-1a", "us-east-1b"]
  type    = list(string)
}

variable "db_engine" {
  default = "postgres"
  type    = string
}

variable "db_version" {
  type    = number
  default = 16
}

variable "db_username" {
  type    = string
  default = "postgres"
}

variable "rds_key_name" {
  type    = string
  default = "rds_postgres_key"
}
