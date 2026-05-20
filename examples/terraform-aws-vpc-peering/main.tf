
# Application VPC 

module "vpc-app" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "vpc-app"
  cidr   = "10.0.0.0/16"

  azs                = ["us-east-1a", "us-east-1b"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Name        = "VPC-APP"
  }
}

# Monitoring VPC
module "vpc-monitoring" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "vpc-monitoring"
  cidr   = "11.0.0.0/16"

  azs                = ["us-east-1a", "us-east-1b"]
  private_subnets    = ["11.0.1.0/24", "11.0.2.0/24"]
  public_subnets     = ["11.0.101.0/24", "11.0.102.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Name        = "VPC-Monitoring"
  }
}

# EC2 Key pair to login to the servers

resource "aws_key_pair" "aws" {
  key_name   = "aws"
  public_key = file(pathexpand("~/.ssh/aws.pub"))
}


# Security Groups for Bastion Servers
resource "aws_security_group" "app-pub" {
  name        = "App-public"
  description = "Allow SSH"
  vpc_id      = module.vpc-app.vpc_id
  ingress {
    description = "allow ssh"
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
  }
  ingress {
    description = "allow ssh from monitoring vpc"
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = [module.vpc-monitoring.vpc_cidr_block]
  }
  ingress {
    description = "allow ping from monitoring vpc"
    from_port   = "8"
    to_port     = "0"
    protocol    = "icmp"
    cidr_blocks = [module.vpc-monitoring.vpc_cidr_block]
  }
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "monitoring-pub" {
  name        = "Monitoring-public"
  description = "Allow SSH"
  vpc_id      = module.vpc-monitoring.vpc_id

  ingress {
    description = "allow ssh"
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
  }
  ingress {
    description = "allow ssh from app vpc"
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = [module.vpc-app.vpc_cidr_block]
  }
  ingress {
    description = "Allow ping from app vpc"
    from_port   = "8"
    to_port     = "0"
    protocol    = "icmp"
    cidr_blocks = [module.vpc-app.vpc_cidr_block]
  }
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Bastion Instances for App and Monitoring

resource "aws_instance" "ec2_app" {
  ami                         = data.aws_ami.ubuntu.id
  subnet_id                   = module.vpc-app.public_subnets[0]
  associate_public_ip_address = true
  instance_type               = "t3.micro"
  vpc_security_group_ids      = [aws_security_group.app-pub.id]
  key_name                    = aws_key_pair.aws.key_name
  tags = {
    Name = "App-shell"
  }
}



resource "aws_instance" "ec2_monitoring" {
  ami                         = data.aws_ami.ubuntu.id
  subnet_id                   = module.vpc-monitoring.public_subnets[0]
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.monitoring-pub.id]
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.aws.key_name
  tags = {
    Name = "monitoring-shell"
  }
}


# Security Groups for Private Instances

resource "aws_security_group" "app-internal" {
  name        = "App-Internal"
  description = "allow SSH from VPC"
  vpc_id      = module.vpc-app.vpc_id
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = [module.vpc-app.vpc_cidr_block]
  }
  ingress {
    from_port   = "8"
    to_port     = "0"
    protocol    = "icmp"
    cidr_blocks = [module.vpc-app.vpc_cidr_block]
  }
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "monitoring-internal" {
  name        = "App-Internal"
  description = "allow SSH from VPC"
  vpc_id      = module.vpc-monitoring.vpc_id
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = [module.vpc-monitoring.vpc_cidr_block]
  }
  ingress {
    from_port   = "8"
    to_port     = "0"
    protocol    = "icmp"
    cidr_blocks = [module.vpc-monitoring.vpc_cidr_block]
  }
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Private Instances for App & Monitoring

resource "aws_instance" "ec2_app_priv" {
  ami                    = data.aws_ami.ubuntu.id
  subnet_id              = module.vpc-app.private_subnets[0]
  vpc_security_group_ids = [aws_security_group.app-internal.id]
  instance_type          = "t3.micro"
  tags = {
    Name = "App-priv"
  }
}

resource "aws_instance" "ec2_monitoring_priv" {
  ami                    = data.aws_ami.ubuntu.id
  subnet_id              = module.vpc-monitoring.private_subnets[0]
  vpc_security_group_ids = [aws_security_group.monitoring-internal.id]
  instance_type          = "t3.micro"
  tags = {
    Name = "monitoring-priv"
  }
}


# Establishing the Peering b/w the App and Monitoring VPC's
resource "aws_vpc_peering_connection" "this" {
  vpc_id      = module.vpc-app.vpc_id
  peer_vpc_id = module.vpc-monitoring.vpc_id
  auto_accept = true

  tags = {
    Name = "app-monitoring-peering"
  }
}

# Add the routes in public and private route tables of vpc-app
resource "aws_route" "app-to-monitoring-priv" {
  count                     = length(module.vpc-app.private_route_table_ids)
  route_table_id            = module.vpc-app.private_route_table_ids[count.index]
  destination_cidr_block    = module.vpc-monitoring.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}

resource "aws_route" "app-to-monitoring-pub" {
  count                     = length(module.vpc-app.public_route_table_ids)
  route_table_id            = module.vpc-app.public_route_table_ids[count.index]
  destination_cidr_block    = module.vpc-monitoring.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}

# Add the routes in public and private route tables of vpc-monitoring
resource "aws_route" "monitoring-to-app-priv" {
  count                     = length(module.vpc-monitoring.private_route_table_ids)
  route_table_id            = module.vpc-monitoring.private_route_table_ids[count.index]
  destination_cidr_block    = module.vpc-app.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}

resource "aws_route" "monitoring-to-app-pub" {
  count                     = length(module.vpc-monitoring.public_route_table_ids)
  route_table_id            = module.vpc-monitoring.public_route_table_ids[count.index]
  destination_cidr_block    = module.vpc-app.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}

