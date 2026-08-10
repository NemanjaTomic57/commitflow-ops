output "nat_public_ips" {
  value = {
    for name, instance in aws_instance.nat :
    name => instance.public_ip
  }
}
