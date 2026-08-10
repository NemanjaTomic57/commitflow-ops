##################################################
# VPC
##################################################

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets in the VPC"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets in the VPC"
  value       = module.vpc.private_subnet_ids
}

##################################################
# Security Groups
##################################################

output "ecs_security_group_id" {
  value = module.security.ecs_security_group_id
}

##################################################
# DB Instance
##################################################

output "ssm_parameter_db_address" {
  value = module.rds.ssm_parameter_db_address
}

output "ssm_parameter_db_port" {
  value = module.rds.ssm_parameter_db_port
}

output "ssm_parameter_db_username" {
  value = module.rds.ssm_parameter_db_username
}

output "ssm_parameter_db_password" {
  value = module.rds.ssm_parameter_db_password
}

output "ssm_parameter_db_url_commitflow" {
  value = module.rds.ssm_parameter_db_url_commitflow
}

output "ssm_parameter_db_url_grafana" {
  value = module.rds.ssm_parameter_db_url_grafana
}

##################################################
# NAT Instances
##################################################

output "nat_public_ips" {
  description = "Public IP addresses of NAT instances"
  value       = module.nat.nat_public_ips
}

##################################################
# Kafka Cluster
##################################################

output "kafka_private_ips" {
  description = "Private IP addresses of Kafka nodes"
  value       = module.kafka.kafka_private_ips
}

output "ssm_parameter_kafka_bootstrap_server" {
  description = "IP addresses for the Kafka bootstrap server"
  value       = module.kafka.ssm_parameter_kafka_bootstrap_server
}

##################################################
# SSM Parameters
##################################################

output "ssm_parameter_github_pat" {
  value = aws_ssm_parameter.github_pat.arn
}

output "ssm_parameter_gitlab_pat" {
  value = aws_ssm_parameter.gitlab_pat.arn
}

output "ssm_parameter_grafana_username" {
  value = aws_ssm_parameter.grafana_username.arn
}

output "ssm_parameter_grafana_password" {
  value = aws_ssm_parameter.grafana_password.arn
}
