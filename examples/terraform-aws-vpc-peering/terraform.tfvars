# 
# Global Common Variable Values
#

azs         = ["us-east-1a", "us-east-1b"]
project     = "terraform-vpc-peering"
environment = "dev"

# 
# App VPC variable values
#
vpc-app-name         = "vpc-app"
vpc-app-cidr         = "10.0.0.0/16"
vpc-app-priv-subnets = ["10.0.1.0/24", "10.0.2.0/24"]
vpc-app-pub-subnets  = ["10.0.101.0/24", "10.0.102.0/24"]


#
# Monitoring VPC variable values
#
vpc-monitoring-name         = "vpc-monitoring"
vpc-monitoring-cidr         = "11.0.0.0/16"
vpc-monitoring-priv-subnets = ["11.0.1.0/24", "11.0.2.0/24"]
vpc-monitoring-pub-subnets  = ["11.0.101.0/24", "11.0.102.0/24"]
