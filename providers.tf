provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Owner       = var.owner
      Environment = var.environment
      Project     = var.project
      ManagedBy   = var.managed_by
    }
  }
}