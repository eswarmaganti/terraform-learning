terraform {
  required_providers {
    aws = {
      version = "~>5.7"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "default"
}
