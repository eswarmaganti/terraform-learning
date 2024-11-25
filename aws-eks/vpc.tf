data "aws_availability_zones" "azs" {
  state = "available"
}

module "vpc" {
  source           = "terraform-aws-modules/vpc/aws"
  version          = "~>5.16"
  name             = var.vpc_name
  cidr             = var.vpc_cidr
  azs              = data.aws_availability_zones.azs.names
  public_subnets   = var.subnets_public_cidr
  private_subnets  = var.subnets_private_cidr
  database_subnets = var.subnets_database_cidr

  database_subnet_group_name = "rds-subnet-group"
  enable_nat_gateway         = true
  single_nat_gateway         = true

  public_subnet_tags = {
    "Name" = "VPC Public Subnet"
  }
  private_subnet_tags = {
    "Name" = "VPC Private Subnet"
  }
  database_subnet_tags = {
    "Name" = "RDS DB Subnet"
  }
}
