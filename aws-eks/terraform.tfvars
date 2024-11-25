vpc_name              = "eks-vpc"
vpc_cidr              = "10.0.0.0/16"
subnets_private_cidr  = ["10.0.1.0/24", "10.0.2.0/24"]
subnets_public_cidr   = ["10.0.3.0/24", "10.0.4.0/24"]
subnets_intra_cidr    = ["10.0.7.0/24", "10.0.8.0/24"]
subnets_database_cidr = ["10.0.5.0/24", "10.0.6.0/24"]
eks_name              = "dev-eks-cluster"
