terraform {
  backend "s3" {
    bucket = "terraform-761018874759"
    key    = "commitflow-ecs.tfstate"
    region = "eu-central-1"
  }
}

##################################################
# Terraform Output Values
##################################################

data "terraform_remote_state" "base" {
  backend = "s3"

  config = {
    bucket = "terraform-761018874759"
    key    = "commitflow-base.tfstate"
    region = "eu-central-1"
  }
}

locals {
  name                  = "commitflow"
  aws_region            = "eu-central-1"
  public_subnet_ids     = data.terraform_remote_state.base.outputs.public_subnet_ids
  private_subnet_ids    = data.terraform_remote_state.base.outputs.private_subnet_ids
  ecs_security_group_id = data.terraform_remote_state.base.outputs.ecs_security_group_id
}

##################################################
# IAM
##################################################

module "iam" {
  source = "./modules/iam"

  name = local.name
}

##################################################
# ECS Task Definitions
##################################################

module "task_definitions" {
  source = "./modules/task_definitions"

  name       = local.name
  aws_region = local.aws_region

  ecs_task_role_arn             = ""
  ecs_execution_role_arn        = module.iam.ecs_task_execution_role_arn
  ecr_commitflow_repository_url = "761018874759.dkr.ecr.eu-central-1.amazonaws.com/commitflow"
}

##################################################
# ECS Cluster
##################################################

resource "aws_ecs_cluster" "commitflow" {
  name   = local.name
  region = local.aws_region
}

##################################################
# ECS Services
##################################################

resource "aws_ecs_service" "producer" {
  name                 = "producer"
  cluster              = aws_ecs_cluster.commitflow.id
  task_definition      = module.task_definitions.producer_task_definition_arn
  desired_count        = 1
  launch_type          = "FARGATE"
  force_new_deployment = true

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    subnets         = values(local.private_subnet_ids)
    security_groups = [local.ecs_security_group_id]
  }
}

resource "aws_ecs_service" "consumer" {
  name                 = "consumer"
  cluster              = aws_ecs_cluster.commitflow.id
  task_definition      = module.task_definitions.consumer_task_definition_arn
  desired_count        = 1
  launch_type          = "FARGATE"
  force_new_deployment = true

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    subnets         = values(local.private_subnet_ids)
    security_groups = [local.ecs_security_group_id]
  }
}

resource "aws_ecs_service" "grafana" {
  name                 = "grafana"
  cluster              = aws_ecs_cluster.commitflow.id
  task_definition      = module.task_definitions.grafana_task_definition_arn
  desired_count        = 1
  launch_type          = "FARGATE"
  force_new_deployment = true

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    subnets         = values(local.private_subnet_ids)
    security_groups = [local.ecs_security_group_id]
  }
}
