output "repository_url" {
  description = "ECR repository URL. Push application images here."
  value       = module.ecr.repository_url
}
