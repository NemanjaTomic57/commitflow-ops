##################################################
# NAT Instances
##################################################

resource "aws_security_group" "nat" {
  name        = "${var.name}-nat-instance-sg"
  description = "Security group for NAT instances"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name}-nat-instance-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "nat_allow_ssh" {
  security_group_id = aws_security_group.nat.id
  description       = "Allow inbound SSH access to the NAT instance from your network (over the internet gateway)"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_ingress_rule" "nat_allow_http" {
  security_group_id = aws_security_group.nat.id
  description       = "Allow inbound HTTP traffic from servers in the private subnet"

  cidr_ipv4   = var.vpc_cidr
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "nat_allow_https" {
  security_group_id = aws_security_group.nat.id
  description       = "Allow inbound HTTPS traffic from servers in the private subnet"

  cidr_ipv4   = var.vpc_cidr
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

resource "aws_vpc_security_group_egress_rule" "nat_allow_ssh" {
  security_group_id = aws_security_group.nat.id
  description       = "Allow outbound SSH access to the VPC"

  cidr_ipv4   = var.vpc_cidr
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_egress_rule" "nat_allow_http" {
  security_group_id = aws_security_group.nat.id
  description       = "Allow outbound HTTP traffic from servers in the private subnet"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_egress_rule" "nat_allow_https" {
  security_group_id = aws_security_group.nat.id
  description       = "Allow outbound HTTPS traffic from servers in the private subnet"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

resource "aws_vpc_security_group_egress_rule" "nat_allow_postgres" {
  security_group_id = aws_security_group.nat.id
  description       = "Allow outbound access to the PostgreSQL port"

  referenced_security_group_id = aws_security_group.db.id
  from_port                    = 5432
  ip_protocol                  = "tcp"
  to_port                      = 5432
}

resource "aws_vpc_security_group_egress_rule" "nat_allow_grafana" {
  security_group_id = aws_security_group.nat.id
  description       = "Allow Grafana traffic to ECS security group"

  referenced_security_group_id = aws_security_group.ecs.id
  from_port                    = 3000
  ip_protocol                  = "tcp"
  to_port                      = 3000
}

##################################################
# Application Load Balancer
##################################################

resource "aws_security_group" "alb" {
  name        = "${var.name}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name}-alb-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_allow_http" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow inbound HTTP traffic"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "alb_allow_https" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow inbound HTTPS traffic"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

resource "aws_vpc_security_group_egress_rule" "alb_allow_grafana" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow outbound Grafana traffic to ECS"

  referenced_security_group_id = aws_security_group.ecs.id
  from_port                    = 3000
  ip_protocol                  = "tcp"
  to_port                      = 3000
}

##################################################
# Kafka
##################################################

resource "aws_security_group" "kafka" {
  name        = "${var.name}-kafka-sg"
  description = "Security group for Kafka nodes"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name}-kafka-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "kafka_allow_ssh" {
  security_group_id = aws_security_group.kafka.id
  description       = "Allow inbound SSH access from NAT instances"

  referenced_security_group_id = aws_security_group.nat.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

resource "aws_vpc_security_group_ingress_rule" "kafka_allow_kafka" {
  for_each = {
    kafka = aws_security_group.kafka.id
    ecs   = aws_security_group.ecs.id
  }

  security_group_id = aws_security_group.kafka.id
  description       = "Allow inbound Kafka traffic"

  referenced_security_group_id = each.value
  from_port                    = 9092
  ip_protocol                  = "tcp"
  to_port                      = 9093
}

resource "aws_vpc_security_group_egress_rule" "kafka_allow_http" {
  security_group_id = aws_security_group.kafka.id
  description       = "Allow outbound HTTP traffic over NAT instances"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_egress_rule" "kafka_allow_https" {
  security_group_id = aws_security_group.kafka.id
  description       = "Allow outbound HTTPS traffic over NAT instances"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

resource "aws_vpc_security_group_egress_rule" "kafka_allow_kafka" {
  security_group_id = aws_security_group.kafka.id
  description       = "Allow outbound Kafka traffic to other Kafka nodes"

  referenced_security_group_id = aws_security_group.kafka.id
  from_port                    = 9092
  ip_protocol                  = "tcp"
  to_port                      = 9093
}

##################################################
# RDS
##################################################

resource "aws_security_group" "db" {
  name        = "${var.name}-db-sg"
  description = "Security group for RDS database instance"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name}-db-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "db_allow_postgres" {
  for_each = {
    nat = aws_security_group.nat.id,
    ecs = aws_security_group.ecs.id,
  }

  security_group_id = aws_security_group.db.id
  description       = "Allow inbound access to the PostgreSQL port from ECS services"

  referenced_security_group_id = each.value
  from_port                    = 5432
  ip_protocol                  = "tcp"
  to_port                      = 5432
}

##################################################
# ECS Services
##################################################

resource "aws_security_group" "ecs" {
  name        = "${var.name}-ecs-sg"
  description = "Security group for ECS services"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name}-ecs-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ecs_allow_grafana" {
  security_group_id = aws_security_group.ecs.id
  description       = "Allow inbound Grafana traffic"

  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 3000
  ip_protocol                  = "tcp"
  to_port                      = 3000
}

resource "aws_vpc_security_group_egress_rule" "ecs_allow_http" {
  security_group_id = aws_security_group.ecs.id
  description       = "Allow outbound HTTP traffic"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_egress_rule" "ecs_allow_https" {
  security_group_id = aws_security_group.ecs.id
  description       = "Allow outbound HTTPS traffic"

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

resource "aws_vpc_security_group_egress_rule" "ecs_allow_postgres" {
  security_group_id = aws_security_group.ecs.id
  description       = "Allow outbound access to the PostgreSQL port"

  referenced_security_group_id = aws_security_group.db.id
  from_port                    = 5432
  ip_protocol                  = "tcp"
  to_port                      = 5432
}

resource "aws_vpc_security_group_egress_rule" "ecs_allow_kafka" {
  security_group_id = aws_security_group.ecs.id
  description       = "Allow outbound access to the Kafka broker port"

  referenced_security_group_id = aws_security_group.kafka.id
  from_port                    = 9092
  ip_protocol                  = "tcp"
  to_port                      = 9092
}
