output "nat_security_group_id" {
  value = aws_security_group.nat.id
}

output "kafka_security_group_id" {
  value = aws_security_group.kafka.id
}

output "db_security_group_id" {
  value = aws_security_group.db.id
}

output "ecs_security_group_id" {
  value = aws_security_group.ecs.id
}
