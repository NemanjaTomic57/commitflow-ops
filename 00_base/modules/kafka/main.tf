resource "aws_instance" "kafka" {
  for_each = var.private_subnet_ids

  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = each.value
  vpc_security_group_ids = [var.kafka_security_group_id]

  tags = {
    Name = "${var.name}-kafka-${each.key}"
  }
}

resource "aws_ssm_parameter" "kafka_bootstrap_server" {
  name = "/commitflow/kafka/bootstrap-server"
  type = "String"
  value = join(",", [
    for _, instance in aws_instance.kafka :
    "${instance.private_ip}:9092"
  ])
}
