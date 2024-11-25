variable "vpc_name" {
  type        = string
  description = "the name of the vpc"
}

variable "vpc_cidr" {
  type        = string
  description = "the cidr block of the vpc"
}

variable "subnets_public_cidr" {
  type        = list(string)
  description = "the cidr blocks for public subnets"
}

variable "subnets_private_cidr" {
  type        = list(string)
  description = "the cidr blocks for private subnets"
}
variable "subnets_intra_cidr" {
  type        = list(string)
  description = "the cidr blocks for Intra subnets"
}

variable "subnets_database_cidr" {
  type        = list(string)
  description = "the cidr blocks for database subnets"
}

variable "eks_name" {
  type        = string
  description = "the name of eks cluster"
}


