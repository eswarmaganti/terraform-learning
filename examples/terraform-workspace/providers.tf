terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
    bucket       = "terraform-s3-backend-9ulqtzat"
    key          = "terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}


provider "aws" {
  profile = "default"
  region  = "us-east-1"
}
