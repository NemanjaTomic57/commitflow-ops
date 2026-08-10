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
  vpc_id                = data.terraform_remote_state.base.outputs.vpc_id
  public_subnet_ids     = data.terraform_remote_state.base.outputs.public_subnet_ids
  private_subnet_ids    = data.terraform_remote_state.base.outputs.private_subnet_ids
  alb_security_group_id = data.terraform_remote_state.base.outputs.alb_security_group_id
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
# Application Load Balancer
##################################################

resource "aws_lb" "commitflow" {
  internal           = false
  load_balancer_type = "application"
  security_groups    = [local.alb_security_group_id]
  subnets            = values(local.public_subnet_ids)

  access_logs {
    bucket  = "commitflow-761018874759"
    enabled = true
    prefix  = "aws-alb/access-logs"
  }

  tags = {
    Name = "${local.name}-alb"
  }
}

resource "aws_lb_target_group" "commitflow" {
  vpc_id          = local.vpc_id
  port            = "3000"
  protocol        = "HTTP"
  target_type     = "ip"
  ip_address_type = "ipv4"

  health_check {
    enabled = true
    path    = "/api/health"
  }

  tags = {
    Name = "${local.name}-alb-tg"
  }
}

resource "aws_lb_listener" "commitflow" {
  load_balancer_arn = aws_lb.commitflow.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.commitflow.arn
  }
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

  tags = {
    Name = "${local.name}-ecs-cluster"
  }
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

  tags = {
    Name = "${local.name}-ecs-service-producer"
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

  tags = {
    Name = "${local.name}-ecs-service-consumer"
  }
}

resource "aws_ecs_service" "grafana" {
  depends_on = [aws_lb.commitflow]

  name                 = "grafana"
  cluster              = aws_ecs_cluster.commitflow.id
  task_definition      = module.task_definitions.grafana_task_definition_arn
  desired_count        = 3
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

  load_balancer {
    container_name   = "grafana"
    container_port   = "3000"
    target_group_arn = aws_lb_target_group.commitflow.arn
  }

  tags = {
    Name = "${local.name}-ecs-service-grafana"
  }
}
