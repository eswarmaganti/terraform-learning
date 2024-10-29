# creating the s3 bucket
resource "aws_s3_bucket" "s3_backend" {
  bucket        = var.bucket_name
  force_destroy = true
}


# enabling the bucket versioning
resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.s3_backend.id
  versioning_configuration {
    status = "Enabled"
  }
}

# enabling server side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_sse" {
  bucket = aws_s3_bucket.s3_backend.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


# creating dynamodb table
resource "aws_dynamodb_table" "db_table" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    type = "S"
    name = "LockID"
  }
}


# fetching the details of availability zones in current region
data "aws_availability_zones" "azs" {
  state = "available"
}

resource "aws_security_group" "ec2_sg" {
  name = "Ec2 SG"
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    description = "Allow port 22 to access the instance"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2_instances" {
  for_each                    = { for az in data.aws_availability_zones.azs.names : az => az }
  instance_type               = "t2.micro"
  key_name                    = "jenkins_ec2"
  availability_zone           = each.key
  ami                         = "ami-0866a3c8686eaeeba"
  security_groups             = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true
  tags = {
    "Name" : "${each.key}-EC2"
  }

}
