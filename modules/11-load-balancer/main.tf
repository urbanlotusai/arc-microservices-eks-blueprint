# =============================================================================
# Module: 11-load-balancer
# =============================================================================
# Provisions the Application Load Balancer for Kubernetes Ingress. The EKS
# AWS Load Balancer Controller (installed via the VPC CNI addon from
# 05-eks-addon, post-apply) will annotate this ALB and route traffic to
# services by Ingress rules.
# State file: modules/11-load-balancer/terraform.tfstate
# Depends on: 02-network (vpc_id, public subnets)
#
# Ordering note: this module must be applied after 05-eks-addon so the AWS
# Load Balancer Controller is ready. In the single-state root this was
# expressed as depends_on = [module.eks_addons]; in the independent-state
# world there is no parent module to hold that edge, so ordering is achieved
# purely by the Makefile/apply-module.sh applying modules/ in numeric
# directory order (05 before 11). No depends_on is added here.
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

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.terraform_remote_state.network.outputs.vpc_id]
  }
  tags = { Type = "public" }
}

# -----------------------------------------------------------------------------
# Load Balancer Module
# -----------------------------------------------------------------------------

module "alb" {
  source  = "sourcefuse/arc-load-balancer/aws"
  version = "0.0.3"

  name       = "${var.namespace}-${var.environment}-alb"
  vpc_id     = data.terraform_remote_state.network.outputs.vpc_id
  subnet_ids = data.aws_subnets.public.ids

  security_group_name = "${var.namespace}-${var.environment}-alb-sg"

  load_balancer_config = {
    internal           = false
    load_balancer_type = "application"
    idle_timeout       = 60
  }

  alb_listener = {
    port     = 80
    protocol = "HTTP"
    default_action = {
      type = "fixed-response"
      fixed_response = {
        content_type = "text/plain"
        message_body = "Not Found"
        status_code  = "404"
      }
    }
  }

  tags = var.tags
}
