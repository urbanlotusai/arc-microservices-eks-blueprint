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
  description = "S3 bucket name for Terraform state"
  type        = string
  default     = ""
}

variable "image_tag_mutability" {
  description = "Whether image tags can be overwritten (MUTABLE or IMMUTABLE)."
  type        = string
  default     = "IMMUTABLE"
}

variable "scan_on_push" {
  description = "Scan container images for vulnerabilities on push."
  type        = bool
  default     = true
}

variable "lifecycle_policy" {
  description = "ECR lifecycle policy JSON document."
  type        = string
  default = jsonencode({
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
}
