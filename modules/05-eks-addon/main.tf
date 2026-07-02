# =============================================================================
# Module: 05-eks-addon
# =============================================================================
# Provisions the AWS-managed EKS addons: VPC CNI, CoreDNS, kube-proxy, and the
# EBS CSI driver.
# State file: modules/05-eks-addon/terraform.tfstate
# Depends on: 04-eks (cluster name)
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
# Data Sources
# -----------------------------------------------------------------------------

data "terraform_remote_state" "eks" {
  backend = "s3"

  config = {
    bucket = var.state_bucket_name
    key    = "modules/04-eks/terraform.tfstate"
    region = var.region
  }
}

# -----------------------------------------------------------------------------
# EKS Addons Module
# -----------------------------------------------------------------------------

module "eks_addons" {
  source  = "sourcefuse/arc-eks-addon/aws"
  version = "1.0.3"

  cluster_name = data.terraform_remote_state.eks.outputs.cluster_id
  addons       = var.addons

  tags = var.tags
}
