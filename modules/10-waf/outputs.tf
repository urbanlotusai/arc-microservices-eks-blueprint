output "arn" {
  description = "ARN of the WAF Web ACL (REGIONAL), for association with the ALB."
  value       = module.waf.arn
}
