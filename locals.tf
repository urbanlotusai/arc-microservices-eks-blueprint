locals {
  name_prefix    = "${var.namespace}-${var.environment}"
  kms_alias      = "alias/${local.name_prefix}-microservices"
  cluster_name   = "${local.name_prefix}-eks"
  db_name        = "${local.name_prefix}-db"
  cache_name     = "${local.name_prefix}-redis"
  sqs_queue_name = "${local.name_prefix}-tasks"
  ecr_repo_name  = "${local.name_prefix}-app"
  waf_name       = "${local.name_prefix}-alb-waf"

  tags = {
    Environment       = var.environment
    Namespace         = var.namespace
    ManagedBy         = "terraform"
    Application       = "microservices-eks"
    ComplianceProfile = var.compliance_profile
  }

  is_strict          = var.compliance_profile == "hipaa"
  log_retention_days = local.is_strict ? 365 : 90
}
