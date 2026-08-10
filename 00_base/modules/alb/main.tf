resource "aws_lb" "commitflow" {
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = values(var.public_subnet_ids)

  access_logs {
    bucket  = "commitflow-761018874759"
    enabled = true
    prefix  = "aws-alb/access-logs"
  }

  tags = {
    Name = "${var.name}-alb"
  }
}

resource "aws_lb_target_group" "commitflow" {
  vpc_id          = var.vpc_id
  port            = "3000"
  protocol        = "HTTP"
  target_type     = "ip"
  ip_address_type = "ipv4"

  health_check {
    enabled = true
    path    = "/api/health"
  }

  tags = {
    Name = "${var.name}-alb-tg"
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
