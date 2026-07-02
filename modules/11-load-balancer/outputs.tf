output "dns_name" {
  description = "ALB DNS name — point your Ingress annotations here."
  value       = module.alb.dns_name
}

output "arn" {
  description = "ARN of the ALB."
  value       = module.alb.arn
}

output "target_group_arn" {
  description = "ARN of the default ALB target group."
  value       = module.alb.target_group_arn
}
