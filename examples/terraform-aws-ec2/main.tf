# resources for security groups
resource "aws_security_group" "ec2_sg" {
  name = "ec2-sg"
  tags = {
    "Name" : "EC2 SG for Flask App"
  }

  ingress {
    protocol    = "tcp"
    from_port   = "22"
    to_port     = "22"
    description = "Allow port 22 for SSH"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = "8000"
    to_port     = "8000"
    description = "Allow PORT 5000 to access the flask application"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol    = "-1"
    from_port   = "0"
    to_port     = "0"
    description = "Allow public internet access from the instances"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

# fething the available availability-zones under current region
data "aws_availability_zones" "azs" {
  state = "available"
}

data "aws_ami" "ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20240927"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# creating one ec2 instance per az
resource "aws_instance" "ec2_servers_count" {
  count = length(data.aws_availability_zones.azs.names)
  #for_each               = { for az in data.aws_availability_zones.azs.names : az => az }
  availability_zone      = data.aws_availability_zones.azs.names[count.index]
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.ami.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = "jenkins_ec2"
  tags = {
    "Name" = "EC2-${data.aws_availability_zones.azs.names[count.index]}"
  }
}


# creating ec2 instances using for_each in each AZ
resource "aws_instance" "ec2_servers_foreach" {
  for_each               = toset(data.aws_availability_zones.azs.names)
  availability_zone      = each.key
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.ami.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = "jenkins_ec2"
  tags = {
    "Name" = "EC2-${each.key}"
  }
}
