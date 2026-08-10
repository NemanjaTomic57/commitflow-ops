output "kafka_private_ips" {
  value = {
    for name, instance in aws_instance.kafka :
    name => instance.private_ip
  }
}

output "ssm_parameter_kafka_bootstrap_server" {
  value = aws_ssm_parameter.kafka_bootstrap_server.arn
}
