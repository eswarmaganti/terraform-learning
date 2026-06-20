terraform {
  required_providers {
    aws = {
      version = "~> 6.0"
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  profile = "default"
}


variable "ingress_rules" {
  type = list(object({
    from_port = string
    to_port = string
    protocol = string
    cidr_blocks = list(string)
  }))
  description = "The variable to store the settings for security group ingress rules"
  default = [
    {
      from_port = "80",
      to_port = "80",
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port = "22"
      to_port = "22"
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

}


variable "filters" {
  type = list(object({
    name = string
    values = list(string)
  }))
  description = "The filters for AMI data source"
  default = [
    {
      name = "name"
      values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-*"]
    },
    {
      name = "root-device-type"
      values = ["ebs"]
    },
    {
      name = "virtualization-type"
      values = ["hvm"]
    },
    {
      name = "architecture"
      values = ["x86_64"]
    }
  ]
}

data "aws_ami" "this" {
  most_recent = true
  owners = ["amazon"]

  dynamic "filter" {
    for_each = var.filters
    content {
      name = filter.value["name"]
      values = filter.value["values"]
    }
  }
}

resource "aws_security_group" "this" {
  name = "Sample-SG"
  description = "The security group allows, inbound SSH (22) & HTTP (80) and outbound traffic"

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port = ingress.value["from_port"]
      to_port = ingress.value["to_port"]
      protocol = ingress.value["protocol"]
      cidr_blocks = ingress.value["cidr_blocks"]
    }
  }

  egress {
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "this" {
  ami = data.aws_ami.this.id
  vpc_security_group_ids = [aws_security_group.this.id]
  instance_type = "t3.micro"
  tags = {
    Name = "Test-VM"
    ManagedBy = "Terrafrom Dynamic Blocks"
  }
}