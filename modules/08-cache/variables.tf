variable "namespace" {
  description = "Organization or team namespace"
  type        = string
  default     = "arc"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
    Project   = "arc-microservices-eks-blueprint"
  }
}

variable "state_bucket_name" {
  description = "S3 bucket name for Terraform state (used to read 01-kms, 02-network, and 03-security-group remote state)"
  type        = string
}

variable "node_type" {
  description = "ElastiCache Redis node type."
  type        = string
  default     = "cache.t3.medium"
}

variable "num_cache_nodes" {
  description = "Number of cache nodes in the replication group."
  type        = number
  default     = 2
}

variable "automatic_failover_enabled" {
  description = "Enable automatic failover to a replica if the primary node fails."
  type        = bool
  default     = true
}
