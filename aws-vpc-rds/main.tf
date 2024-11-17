
# creating the VPC Resource
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    "Name" = "RDS VPC"
  }
}

# creating the public subnets
resource "aws_subnet" "subnets_public" {
  count             = length(var.subnets_public_cidr)
  cidr_block        = var.subnets_public_cidr[count.index]
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.subnets_public_azs[count.index]
}

# creating the private subnets
resource "aws_subnet" "subnets_private" {
  count             = length(var.subnets_private_cidr)
  cidr_block        = var.subnets_private_cidr[count.index]
  vpc_id            = aws_vpc.vpc.id
  availability_zone = var.subnets_private_azs[count.index]
}

# creating the route table
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name" = "RDS Route Table"
  }
}

# creating the internet gateway to allow internet access to public subnets
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name" = "Internet GateWay"
  }
}

# creating the route to allow traffic to subnets
resource "aws_route" "route_table_route" {
  gateway_id             = aws_internet_gateway.igw.id
  route_table_id         = aws_route_table.route_table.id
  destination_cidr_block = "0.0.0.0/0"
}

# creating the route table associations for subnets
resource "aws_route_table_association" "route_table_assoc" {
  count          = length(aws_subnet.subnets_public)
  subnet_id      = aws_subnet.subnets_public[count.index].id
  route_table_id = aws_route_table.route_table.id
}

# creating elastic ip for nat gateway
resource "aws_eip" "ngw-eip" {
  depends_on = [aws_internet_gateway.igw]
  domain     = "vpc"
}

# creating the nat gateway
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.ngw-eip.id
  subnet_id     = aws_subnet.subnets_private[0].id
  depends_on    = [aws_internet_gateway.igw]
  tags = {
    "Name" = "Nat GateWay"
  }
}

# creating route table for natgateway
resource "aws_route_table" "ngw_route_table" {
  vpc_id     = aws_vpc.vpc.id
  depends_on = [aws_nat_gateway.ngw]
  tags = {
    "Name" = "Private Route Table"
  }
}

# creating the routes for private routes
resource "aws_route" "ngw_route" {
  nat_gateway_id         = aws_nat_gateway.ngw.id
  route_table_id         = aws_route_table.ngw_route_table.id
  destination_cidr_block = "0.0.0.0/0"
}

# creating route table associations for private subnets
resource "aws_route_table_association" "private_route_table_assoc" {
  count          = length(aws_subnet.subnets_private)
  subnet_id      = aws_subnet.subnets_private[count.index].id
  route_table_id = aws_route_table.ngw_route_table.id
}

# creating the subnet group for RDS Instance
resource "aws_db_subnet_group" "rds_subnet_group" {
  subnet_ids = [for subnet in aws_subnet.subnets_private : subnet.id]
  name       = "rds-subnet-group"
  tags = {
    "Name" = "RDS subnet group"
  }
}

# creating the credentials for rds
resource "random_password" "rds_password" {
  length  = 16
  special = false
}

# resource "aws_secretsmanager_secret" "rds_creds_postgres" {
#   name = "rds_creds_postgres"
#   tags = {
#     "Name" = "RDS Credentials"
#   }
# }

# resource "aws_secretsmanager_secret_version" "rds_creds_value" {
#   secret_id     = aws_secretsmanager_secret.rds_creds_postgres.arn
#   secret_string = random_password.rds_password.result
# }

# data "aws_secretsmanager_secret_version" "rds_password" {
#   secret_id = aws_secretsmanager_secret.rds_creds_postgres.arn
# }

# security group for rds instance
resource "aws_security_group" "rds-sg" {
  name        = "RDS-SG"
  description = "Security Group for RDS"
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    description = "Allow access to the database from public internet"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = -1
    description = "Allow instance to access public internet"
  }
}

# creating the rds instance
resource "aws_db_instance" "rds_postgres" {
  allocated_storage      = var.rds_storage
  engine                 = "postgres"
  engine_version         = 16
  db_name                = "postgres"
  instance_class         = var.rds_instance_class
  username               = "postgres"
  password               = random_password.rds_password.result
  skip_final_snapshot    = true
  publicly_accessible    = true
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds-sg.id]
}
