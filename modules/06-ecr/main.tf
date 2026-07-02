# =============================================================================
# Module: 06-ecr
# =============================================================================
# Provisions the ECR repository that application container images are pushed
# to and pulled from by the EKS cluster.
# State file: modules/06-ecr/terraform.tfstate
# =============================================================================

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 7.0"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = var.region

  default_tags {
    tags = var.tags
  }
}

# -----------------------------------------------------------------------------
# ECR Module
# -----------------------------------------------------------------------------

module "ecr" {
  source  = "sourcefuse/arc-ecr/aws"
  version = "0.0.4"

  name                 = "${var.namespace}-${var.environment}-app"
  image_tag_mutability = var.image_tag_mutability
  scan_on_push         = var.scan_on_push
  lifecycle_policy     = var.lifecycle_policy

  tags = var.tags
}
