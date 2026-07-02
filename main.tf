# ═══════════════════════════════════════════════════════════════════════════════
# 1. KMS — root of the encryption trust chain
# ═══════════════════════════════════════════════════════════════════════════════
module "kms" {
  source = "./modules/01-kms"

  alias                   = local.kms_alias
  policy                  = data.aws_iam_policy_document.kms.json
  description             = "CMK for ${local.name_prefix} microservices on EKS"
  deletion_window_in_days = var.kms_deletion_window

  tags = local.tags
}

# ═══════════════════════════════════════════════════════════════════════════════
# 2. Network — VPC + subnets
# ═══════════════════════════════════════════════════════════════════════════════
module "network" {
  source = "./modules/02-network"

  name        = local.name_prefix
  namespace   = var.namespace
  environment = var.environment
  cidr_block  = var.vpc_cidr

  tags = local.tags
}

# ═══════════════════════════════════════════════════════════════════════════════
# 3. Security Group — cluster and service access control
# ═══════════════════════════════════════════════════════════════════════════════
module "security_group" {
  source = "./modules/03-security-group"

  name        = "${local.name_prefix}-platform"
  description = "Security group for EKS nodes, Aurora, and ElastiCache"
  vpc_id      = module.network.vpc_id

  ingress_rules = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr]
      description = "PostgreSQL from VPC"
    },
    {
      from_port   = 6379
      to_port     = 6379
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr]
      description = "Redis from VPC"
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound"
    }
  ]

  tags = local.tags
}

# ═══════════════════════════════════════════════════════════════════════════════
# 4. EKS — Kubernetes cluster with managed node groups
#    Outputs consumed by: module.eks_addons, kubernetes/helm providers
# ═══════════════════════════════════════════════════════════════════════════════
module "eks" {
  source = "./modules/04-eks"

  name        = local.cluster_name
  namespace   = var.namespace
  environment = var.environment

  kubernetes_version = var.kubernetes_version

  vpc_config = {
    vpc_id             = module.network.vpc_id
    subnet_ids         = data.aws_subnets.private.ids
    security_group_ids = [module.security_group.id]
  }

  cluster_encryption_config = [
    {
      provider_key_arn = module.kms.key_arn
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

  tags = local.tags
}

# ═══════════════════════════════════════════════════════════════════════════════
# 5. EKS Addons — VPC CNI, CoreDNS, kube-proxy, EBS CSI
# ═══════════════════════════════════════════════════════════════════════════════
module "eks_addons" {
  source = "./modules/05-eks-addon"

  cluster_name = module.eks.cluster_id

  addons = {
    vpc-cni            = { addon_version = "v1.16.0-eksbuild.1" }
    coredns            = { addon_version = "v1.11.1-eksbuild.4" }
    kube-proxy         = { addon_version = "v1.29.0-eksbuild.1" }
    aws-ebs-csi-driver = { addon_version = "v1.26.0-eksbuild.1" }
  }

  tags = local.tags
}

# ═══════════════════════════════════════════════════════════════════════════════
# 6. ECR — container image registry
# ═══════════════════════════════════════════════════════════════════════════════
module "ecr" {
  source = "./modules/06-ecr"

  name                 = local.ecr_repo_name
  image_tag_mutability = "IMMUTABLE"
  scan_on_push         = true

  lifecycle_policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Expire untagged images after 1 day"
      selection = {
        tagStatus   = "untagged"
        countType   = "sinceImagePushed"
        countUnit   = "days"
        countNumber = 1
      }
      action = { type = "expire" }
    }]
  })

  tags = local.tags
}

# ═══════════════════════════════════════════════════════════════════════════════
# 7. Aurora DB — persistent data store
# ═══════════════════════════════════════════════════════════════════════════════
module "db" {
  source = "./modules/07-db"

  name        = local.db_name
  namespace   = var.namespace
  environment = var.environment

  engine         = var.db_engine
  engine_version = var.db_engine_version
  port           = var.db_engine == "aurora-postgresql" ? 5432 : 3306

  username = var.db_username

  vpc_id = module.network.vpc_id
  db_subnet_group_data = {
    subnet_ids = data.aws_subnets.private.ids
  }

  kms_key_id              = module.kms.key_arn
  instance_class          = var.db_instance_class
  backup_retention_period = local.is_strict ? 35 : 7
  deletion_protection     = local.is_strict

  tags = local.tags
}

# ═══════════════════════════════════════════════════════════════════════════════
# 8. ElastiCache Redis — session store and caching layer
# ═══════════════════════════════════════════════════════════════════════════════
module "cache" {
  source = "./modules/08-cache"

  name               = local.cache_name
  namespace          = var.namespace
  environment        = var.environment
  vpc_id             = module.network.vpc_id
  subnet_ids         = data.aws_subnets.private.ids
  security_group_ids = [module.security_group.id]

  node_type       = var.cache_node_type
  num_cache_nodes = 2

  kms_key_id                  = module.kms.key_arn
  automatic_failover_enabled  = true

  tags = local.tags
}

# ═══════════════════════════════════════════════════════════════════════════════
# 9. SQS — inter-service task queue with DLQ
# ═══════════════════════════════════════════════════════════════════════════════
module "sqs" {
  source = "./modules/09-sqs"

  name = local.sqs_queue_name

  message_config = {
    visibility_timeout        = 300
    retention_seconds         = 345600
    receive_wait_time_seconds = 20
  }

  kms_config = {
    key_arn    = module.kms.key_arn
    create_key = false
  }

  dlq_config = {
    enabled           = true
    name              = "${local.sqs_queue_name}-dlq"
    max_receive_count = local.is_strict ? 1 : 3
  }

  tags = local.tags
}

# ═══════════════════════════════════════════════════════════════════════════════
# 10. WAF — ALB-scoped Web ACL (REGIONAL) for the Ingress load balancer
# ═══════════════════════════════════════════════════════════════════════════════
module "waf" {
  source = "./modules/10-waf"

  web_acl_name           = local.waf_name
  web_acl_default_action = "ALLOW"
  web_acl_scope          = "REGIONAL"

  web_acl_visibility_config = {
    cloudwatch_metrics_enabled = true
    metric_name                = "${local.name_prefix}-waf"
    sampled_requests_enabled   = true
  }

  web_acl_rules = [
    {
      name     = "RateLimit"
      priority = 1
      action   = "block"
      statement = {
        rate_based_statement = {
          limit              = local.waf_rate_limit
          aggregate_key_type = "IP"
        }
      }
      visibility_config = {
        cloudwatch_metrics_enabled = true
        metric_name                = "${local.name_prefix}-rate-limit"
        sampled_requests_enabled   = true
      }
    }
  ]

  tags = local.tags
}

# ═══════════════════════════════════════════════════════════════════════════════
# 11. Load Balancer — ALB for Kubernetes Ingress
#     EKS AWS Load Balancer Controller (installed via Helm post-apply) will
#     annotate this ALB and route traffic to services by Ingress rules.
# ═══════════════════════════════════════════════════════════════════════════════
module "alb" {
  source = "./modules/11-load-balancer"

  name       = "${local.name_prefix}-alb"
  vpc_id     = module.network.vpc_id
  subnet_ids = data.aws_subnets.public.ids

  security_group_name = "${local.name_prefix}-alb-sg"

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

  tags = local.tags

  depends_on = [module.eks_addons]
}
