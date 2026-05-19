
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

# security group for rds instance
resource "aws_security_group" "rds-sg" {
  name        = "RDS-SG"
  description = "Security Group for RDS"
  vpc_id      = aws_vpc.vpc.id
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
  allocated_storage           = var.rds_storage
  identifier                  = "postgres"
  engine                      = var.db_engine
  engine_version              = var.db_version
  db_name                     = "postgres"
  instance_class              = var.rds_instance_class
  username                    = var.db_username
  skip_final_snapshot         = true
  db_subnet_group_name        = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids      = [aws_security_group.rds-sg.id]
  manage_master_user_password = true
}


resource "aws_key_pair" "rds_key_pair" {
  key_name   = var.rds_key_name
  public_key = file("/Users/eswarmaganti/.ssh/rds_postgres_key.pub")
}

data "aws_ami" "ubuntu_ami" {
  most_recent = "true"
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20240927"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

# security group for ec2 instance
resource "aws_security_group" "bation_sg" {
  name   = "SG for Bation EC2 Instance"
  vpc_id = aws_vpc.vpc.id
  ingress {
    protocol    = "tcp"
    description = "allow PORT 22 to ssh"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow public internet to instance"
  }
}

# aws bation ec2 instance
resource "aws_instance" "bation_instance" {
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.rds_key_pair.key_name
  ami                    = data.aws_ami.ubuntu_ami.id
  subnet_id              = aws_subnet.subnets_public[0].id
  vpc_security_group_ids = [aws_security_group.bation_sg.id]
}


# creating an elastic ip to connect db
resource "aws_eip" "bation_ec2_ip" {
  domain   = "vpc"
  instance = aws_instance.bation_instance.id

  tags = {
    "Name" = "EIP Bation"
  }
}
