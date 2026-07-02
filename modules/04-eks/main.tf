# =============================================================================
# Module: 04-eks
# =============================================================================
# Provisions the EKS cluster and managed node groups.
# State file: modules/04-eks/terraform.tfstate
# Depends on: 02-network (vpc_id, private subnets), 03-security-group
#             (security group id), 01-kms (cluster secrets encryption key)
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

data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = var.state_bucket_name
    key    = "modules/02-network/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "security_group" {
  backend = "s3"

  config = {
    bucket = var.state_bucket_name
    key    = "modules/03-security-group/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "kms" {
  backend = "s3"

  config = {
    bucket = var.state_bucket_name
    key    = "modules/01-kms/terraform.tfstate"
    region = var.region
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.terraform_remote_state.network.outputs.vpc_id]
  }
  tags = { Type = "private" }
}

# -----------------------------------------------------------------------------
# EKS Module
# -----------------------------------------------------------------------------

module "eks" {
  source  = "sourcefuse/arc-eks/aws"
  version = "6.0.4"

  name        = "${var.namespace}-${var.environment}-eks"
  namespace   = var.namespace
  environment = var.environment

  kubernetes_version = var.kubernetes_version

  vpc_config = {
    vpc_id             = data.terraform_remote_state.network.outputs.vpc_id
    subnet_ids         = data.aws_subnets.private.ids
    security_group_ids = [data.terraform_remote_state.security_group.outputs.id]
  }

  cluster_encryption_config = [
    {
      provider_key_arn = data.terraform_remote_state.kms.outputs.key_arn
      resources        = ["secrets"]
    }
  ]

  managed_node_groups = {
    platform = {
      instance_types = var.node_instance_types
      desired_size   = var.node_desired_size
      min_size       = var.node_min_size
      max_size       = var.node_max_size
      disk_size      = 50
    }
  }

  tags = var.tags
}
