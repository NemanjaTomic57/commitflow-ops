##################################################
# VPC Data
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
  ssm_parameter_github_pat            = data.terraform_remote_state.base.outputs.ssm_parameter_github_pat
  ssm_parameter_gitlab_pat            = data.terraform_remote_state.base.outputs.ssm_parameter_gitlab_pat
  ssm_parameter_kafka_bootstrap_sever = data.terraform_remote_state.base.outputs.ssm_parameter_kafka_bootstrap_server
  ssm_parameter_grafana_username      = data.terraform_remote_state.base.outputs.ssm_parameter_grafana_username
  ssm_parameter_grafana_password      = data.terraform_remote_state.base.outputs.ssm_parameter_grafana_password
  ssm_parameter_db_url_commitflow     = data.terraform_remote_state.base.outputs.ssm_parameter_db_url_commitflow
  ssm_parameter_db_url_grafana        = data.terraform_remote_state.base.outputs.ssm_parameter_db_url_grafana
  ssm_parameter_db_address            = data.terraform_remote_state.base.outputs.ssm_parameter_db_address
  ssm_parameter_db_name               = data.terraform_remote_state.base.outputs.ssm_parameter_db_name
  ssm_parameter_db_username           = data.terraform_remote_state.base.outputs.ssm_parameter_db_username
  ssm_parameter_db_password           = data.terraform_remote_state.base.outputs.ssm_parameter_db_password
}

##################################################
# Cloud Watch
##################################################

resource "aws_cloudwatch_log_group" "this" {
  name = "/ecs/${var.name}"
}

##################################################
# ECS Task Definition CommitFlow Producer
##################################################

resource "aws_ecs_task_definition" "commitflow_producer" {
  family                   = "commitflow-producer"
  requires_compatibilities = ["FARGATE"]

  network_mode = "awsvpc"
  cpu          = "256"
  memory       = "512"

  task_role_arn      = var.ecs_task_role_arn
  execution_role_arn = var.ecs_execution_role_arn

  runtime_platform {
    operating_system_family = "LINUX"
  }

  pid_mode = "task"

  container_definitions = jsonencode([
    {
      name      = "producer"
      image     = "${var.ecr_commitflow_url}:latest"
      essential = true

      command = [
        "producer",
        "-bootstrap"
      ]

      secrets = [
        {
          name      = "KAFKA_BOOTSTRAP_SERVER"
          valueFrom = local.ssm_parameter_kafka_bootstrap_sever
        },
        {
          name      = "GITHUB_PAT"
          valueFrom = local.ssm_parameter_github_pat
        },
        {
          name      = "GITLAB_PAT"
          valueFrom = local.ssm_parameter_gitlab_pat
        }
      ]

      linuxParameters = {
        initProcessEnabled = true
      }

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "producer"
        }
      }
    }
  ])

  tags = {
    Name = "${var.name}-commitflow-producer"
  }
}

##################################################
# ECS Task Definition CommitFlow Consumer
##################################################

resource "aws_ecs_task_definition" "commitflow_consumer" {
  family                   = "commitflow-consumer"
  requires_compatibilities = ["FARGATE"]

  network_mode = "awsvpc"
  cpu          = "256"
  memory       = "512"

  task_role_arn      = var.ecs_task_role_arn
  execution_role_arn = var.ecs_execution_role_arn

  runtime_platform {
    operating_system_family = "LINUX"
  }

  pid_mode = "task"

  container_definitions = jsonencode([
    {
      name      = "consumer"
      image     = "${var.ecr_commitflow_url}:latest"
      essential = true

      command = ["consumer"]

      secrets = [
        {
          name      = "CONNECTION_STRING"
          valueFrom = local.ssm_parameter_db_url_commitflow
        },
        {
          name      = "KAFKA_BOOTSTRAP_SERVER"
          valueFrom = local.ssm_parameter_kafka_bootstrap_sever
        }
      ]

      linuxParameters = {
        initProcessEnabled = true
      }

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "consumer"
        }
      }
    }
  ])

  tags = {
    Name = "${var.name}-commitflow-consumer"
  }
}

##################################################
# ECS Task Definition Grafana
##################################################

resource "aws_ecs_task_definition" "grafana" {
  family                   = "grafana"
  requires_compatibilities = ["FARGATE"]

  network_mode = "awsvpc"
  cpu          = "256"
  memory       = "512"

  task_role_arn      = var.ecs_task_role_arn
  execution_role_arn = var.ecs_execution_role_arn

  runtime_platform {
    operating_system_family = "LINUX"
  }

  pid_mode = "task"

  container_definitions = jsonencode([
    {
      name      = "grafana"
      image     = "${var.ecr_commitflow_grafana_url}"
      essential = true

      portMappings = [
        {
          containerPort = 3000
        }
      ]

      healthcheck = {
        command = [
          "CMD-SHELL",
          "curl -f http://localhost:3000/api/health || exit 1"
        ]
        interval    = 10
        timeout     = 5
        retires     = 3
        startPeriod = 30
      }

      secrets = [
        {
          name      = "GF_SECURITY_ADMIN_USER"
          valueFrom = local.ssm_parameter_grafana_username
        },
        {
          name      = "GF_SECURITY_ADMIN_PASSWORD"
          valueFrom = local.ssm_parameter_grafana_password
        },
        {
          name      = "GF_DATABASE_URL"
          valueFrom = local.ssm_parameter_db_url_grafana
        },
        {
          name      = "DB_HOST"
          valueFrom = local.ssm_parameter_db_address
        },
        {
          name      = "DB_DATABASE"
          valueFrom = local.ssm_parameter_db_name
        },
        {
          name      = "DB_USER"
          valueFrom = local.ssm_parameter_db_username
        },
        {
          name      = "DB_PASSWORD"
          valueFrom = local.ssm_parameter_db_password
        },
      ]

      linuxParameters = {
        initProcessEnabled = true
      }

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "grafana"
        }
      }
    }
  ])

  tags = {
    Name = "${var.name}-commitflow-grafana"
  }
}
