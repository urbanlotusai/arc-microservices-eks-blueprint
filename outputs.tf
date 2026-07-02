output "kms_key_arn" {
  description = "ARN of the KMS CMK."
  value       = module.kms.key_arn
}

output "cluster_id" {
  description = "EKS cluster ID."
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "EKS cluster API server endpoint."
  value       = module.eks.cluster_endpoint
}

output "kubeconfig_command" {
  description = "Run this to update your local kubeconfig."
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_id}"
}

output "ecr_repository_url" {
  description = "ECR repository URL. Push your images here."
  value       = module.ecr.repository_url
}

output "db_cluster_endpoint" {
  description = "Aurora writer endpoint."
  value       = module.db.cluster_endpoint
}

output "cache_cluster_address" {
  description = "ElastiCache Redis primary endpoint."
  value       = module.cache.cluster_address
}

output "sqs_queue_url" {
  description = "SQS task queue URL."
  value       = module.sqs.queue_url
}

output "sqs_dlq_url" {
  description = "SQS DLQ URL."
  value       = module.sqs.dead_letter_queue_url
}

output "alb_dns_name" {
  description = "ALB DNS name — point your Ingress annotations here."
  value       = module.alb.dns_name
}

output "waf_arn" {
  description = "WAF Web ACL ARN (REGIONAL) for the ALB."
  value       = module.waf.arn
}
