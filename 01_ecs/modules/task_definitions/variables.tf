variable "name" {
  type        = string
  description = "Name of the application"
}

variable "aws_region" {
  type = string
}

variable "ecs_task_role_arn" {
  type        = string
  description = "ARN of the role for the ECS task role"
}

variable "ecs_execution_role_arn" {
  type        = string
  description = "ARN of the role for the ECS task execution role"
}

variable "ecr_commitflow_url" {
  type        = string
  description = "ECR repository URL for commitflow image"
}

variable "ecr_commitflow_grafana_url" {
  type        = string
  description = "ECR URL for commitflow/grafana image"
}
