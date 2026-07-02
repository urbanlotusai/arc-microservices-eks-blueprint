output "cluster_address" {
  description = "ElastiCache Redis primary endpoint address."
  value       = module.cache.cluster_address
}
