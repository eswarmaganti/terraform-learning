#
# Application VPC Configuration
#
module "vpc-app" {
  source = "terraform-aws-modules/vpc/aws"
  name   = var.vpc-app-name
  cidr   = var.vpc-app-cidr

  azs                = var.azs
  private_subnets    = var.vpc-app-priv-subnets
  public_subnets     = var.vpc-app-pub-subnets
  enable_nat_gateway = true
  single_nat_gateway = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.vpc-app-name}"
    }
  )
}

#
# Monitoring VPC configuration
#
module "vpc-monitoring" {
  source = "terraform-aws-modules/vpc/aws"
  name   = var.vpc-monitoring-name
  cidr   = var.vpc-monitoring-cidr

  azs                = var.azs
  private_subnets    = var.vpc-monitoring-priv-subnets
  public_subnets     = var.vpc-monitoring-pub-subnets
  enable_nat_gateway = true
  single_nat_gateway = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.vpc-monitoring-name}"
    }
  )
}

# EC2 Key pair to login to the servers

resource "aws_key_pair" "aws" {
  key_name   = "aws"
  public_key = file(pathexpand("~/.ssh/aws.pub"))
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

