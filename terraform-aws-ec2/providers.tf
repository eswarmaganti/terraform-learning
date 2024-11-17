terraform {
  required_providers {
    aws = {
        version = "~>5.7"
    }
  }
}

provider "aws" {
  profile = "default"
  region = "us-east-1"
}