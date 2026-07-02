# ── Mandatory ─────────────────────────────────────────────────────────────────

variable "environment" {
  description = "Deployment environment (e.g. prod, staging, dev)."
  type        = string
}

variable "namespace" {
  description = "Project or team namespace used as a resource name prefix."
  type        = string
}

variable "db_password" {
  description = "Master password for the Aurora cluster."
  type        = string
  sensitive   = true
}

# ── Optional ──────────────────────────────────────────────────────────────────

variable "region" {
  description = "AWS region for all resources."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the platform VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "compliance_profile" {
  description = "Compliance overlay profile."
  type        = string
  default     = "general"

  validation {
    condition     = contains(["general", "hipaa"], var.compliance_profile)
    error_message = "compliance_profile must be general or hipaa."
  }
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version."
  type        = string
  default     = "1.29"
}

variable "node_instance_types" {
  description = "EC2 instance types for EKS worker nodes."
  type        = list(string)
  default     = ["m5.xlarge"]
}

variable "node_desired_size" {
  description = "Desired worker node count."
  type        = number
  default     = 3
}

variable "node_min_size" {
  description = "Minimum worker node count."
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum worker node count."
  type        = number
  default     = 10
}

variable "db_engine" {
  description = "Aurora engine: aurora-postgresql or aurora-mysql."
  type        = string
  default     = "aurora-postgresql"
}

variable "db_engine_version" {
  description = "Aurora engine version."
  type        = string
  default     = "15.4"
}

variable "db_instance_class" {
  description = "Aurora instance class."
  type        = string
  default     = "db.r6g.large"
}

variable "db_username" {
  description = "Master username for the Aurora cluster."
  type        = string
  default     = "dbadmin"
}

variable "cache_node_type" {
  description = "ElastiCache Redis node type."
  type        = string
  default     = "cache.t3.medium"
}

variable "kms_deletion_window" {
  description = "Days before KMS key deletion (7–30)."
  type        = number
  default     = 30
}
