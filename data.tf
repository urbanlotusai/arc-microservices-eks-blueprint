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

  statement {
    sid    = "AllowEKS"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
    actions   = ["kms:GenerateDataKey", "kms:Decrypt", "kms:DescribeKey"]
    resources = ["*"]
  }
}

data "aws_eks_cluster_auth" "this" {
  name       = module.eks.cluster_id
  depends_on = [module.eks]
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [module.network.vpc_id]
  }
  tags       = { Type = "private" }
  depends_on = [module.network]
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [module.network.vpc_id]
  }
  tags       = { Type = "public" }
  depends_on = [module.network]
}
