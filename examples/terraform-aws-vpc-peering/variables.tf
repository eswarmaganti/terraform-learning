#
# Global Common Variables
#
variable "environment" {
  description = "The project environment <dev/prod/stage>"
  type        = string
  default     = "dev"
}
variable "project" {
  description = "The name of the project"
  type        = string
  default     = "terraform-vpc-peering"
}

variable "azs" {
  description = "Availability zones for vpc"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

#
# The Variable definitions for VPC App
#
variable "vpc-app-name" {
  description = "The name of the VPC App"
  type        = string
  default     = "vpc-app"
}
variable "vpc-app-cidr" {
  description = "The CIDR block for VPC-App"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc-app-pub-subnets" {
  description = "The public subnet cidr blocks for VPC App"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "vpc-app-priv-subnets" {
  description = "The private subnet cidr blocks for VPC App"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}


#
# The Variable definitions for VPC Monitoring
#

variable "vpc-monitoring-name" {
  description = "The name of the VPC Monitoring"
  type        = string
  default     = "vpc-monitoring"
}
variable "vpc-monitoring-cidr" {
  description = "The CIDR block for VPC-Monitoring"
  type        = string
  default     = "11.0.0.0/16"
}

variable "vpc-monitoring-pub-subnets" {
  description = "The public subnet cidr blocks for VPC Monitoring"
  type        = list(string)
  default     = ["11.0.101.0/24", "11.0.102.0/24"]
}

variable "vpc-monitoring-priv-subnets" {
  description = "The private subnet cidr blocks for VPC Monitoring"
  type        = list(string)
  default     = ["11.0.1.0/24", "11.0.2.0/24"]
}


