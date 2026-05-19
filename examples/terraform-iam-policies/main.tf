# creating an iam role
resource "aws_iam_role" "ec2_iam_role" {
  name = "ec2_iam_role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "sts:AssumeRole"
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        }
      }
    ]
  })
}


# Creating a Customer Managed Poilcy 
resource "aws_iam_policy" "s3_policy" {
  name = "EC2_S3-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : ["s3:*"],
        "Effect" : "Allow",
        "Sid" : "MyEc2Pilicy",
        "Resource" : "*"
      }
    ]
  })
}

# Attaching the Policy ARN to IAM Role
resource "aws_iam_role_policy_attachment" "ec2_policy_attach" {
  role       = aws_iam_role.ec2_iam_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

# Attaching a AWS Managed policy
# resource "aws_iam_role_policy_attachment" "ec2_policy_attach" {
#   role = aws_iam_role.ec2_iam_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
# }

# Creating a instance profile to assign the role to ec2 instance
resource "aws_iam_instance_profile" "instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_iam_role.name
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
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    description = "Allow public internet to the instance"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2_instance" {
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name
  ami                    = "ami-0866a3c8686eaeeba"
  instance_type          = "t2.micro"
  key_name               = "jenkins_ec2"
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
}
