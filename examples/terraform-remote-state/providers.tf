terraform {
  required_providers {
    aws = {
      version = "~>5.7"
    }
  }
  backend "s3" {
    bucket         = "eswarmaganti-terraform-remote-state"
    key            = "global/s3/terraform.tfstate"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    region         = "us-east-1"
  }
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}
