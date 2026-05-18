module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~>20.0"

  cluster_name                             = var.eks_name
  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = ["t2.medium", "t2.large"]
  }
  eks_managed_node_groups = {
    node-grp-one = {
      name           = "worker-group-1"
      instance_types = ["t2.large"]
      min_size       = 1
      max_size       = 3
      desired_size   = 2
    }
    node-grp-two = {
      name           = "worker-group-2"
      instance_types = ["t2.large"]
      min_size       = 1
      max_size       = 3
      desired_size   = 2
    }

  }
  tags = {
    "Name" = "DEV-CLUSTER"
  }
}
