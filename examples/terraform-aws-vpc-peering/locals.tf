locals {
  common_tags = {
    Terraform   = "true"
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}
