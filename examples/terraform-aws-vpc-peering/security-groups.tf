
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
