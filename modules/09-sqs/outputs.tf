output "queue_url" {
  description = "SQS task queue URL."
  value       = module.sqs.queue_url
}

output "queue_arn" {
  description = "SQS task queue ARN."
  value       = module.sqs.queue_arn
}

output "dead_letter_queue_url" {
  description = "SQS DLQ URL."
  value       = module.sqs.dead_letter_queue_url
}

output "dead_letter_queue_arn" {
  description = "SQS DLQ ARN."
  value       = module.sqs.dead_letter_queue_arn
}
