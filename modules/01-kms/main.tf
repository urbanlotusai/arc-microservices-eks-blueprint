# =============================================================================
# Module: 01-kms
# =============================================================================
# Provisions the customer-managed KMS key used to encrypt EKS secrets, Aurora,
# ElastiCache, and SQS in this blueprint.
# State file: modules/01-kms/terraform.tfstate
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

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "kms" {
  statement {
    sid    = "AllowAccountRoot"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  # EKS requires kms:GenerateDataKey, kms:Decrypt, and kms:DescribeKey to
  # encrypt Kubernetes secrets with this CMK.
  statement {
    sid    = "AllowEKS"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }
}

# -----------------------------------------------------------------------------
# KMS Module
# -----------------------------------------------------------------------------

module "kms" {
  source  = "sourcefuse/arc-kms/aws"
  version = "1.0.11"

  alias                   = "alias/${var.namespace}-${var.environment}-microservices"
  policy                  = data.aws_iam_policy_document.kms.json
  description             = "CMK for ${var.namespace}-${var.environment} microservices on EKS"
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = true

  tags = var.tags
}
