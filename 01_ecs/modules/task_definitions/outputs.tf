output "producer_task_definition_arn" {
  description = "ARN of the task definition for the CommitFlow producer"
  value       = aws_ecs_task_definition.commitflow_producer.arn
}

output "consumer_task_definition_arn" {
  description = "ARN of the task definition for the CommitFlow consumer"
  value       = aws_ecs_task_definition.commitflow_consumer.arn
}

output "grafana_task_definition_arn" {
  description = "ARN of the task definition for Grafana"
  value       = aws_ecs_task_definition.grafana.arn
}
