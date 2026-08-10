output "ecs_cluster_id" {
  description = "ID of the ECS cluster"
  value       = aws_ecs_cluster.commitflow.id
}

output "alb_url" {
  description = "URL for the ALB"
  value       = local.alb_url
}
