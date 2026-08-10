locals {
  nat_for_private = zipmap(
    keys(var.private_subnet_ids),
    keys(var.public_subnet_ids)
  )
}

##################################################
# NAT Instances
##################################################

resource "aws_instance" "nat" {
  for_each = var.public_subnet_ids

  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = each.value
  vpc_security_group_ids = [var.nat_security_group_id]
  source_dest_check      = false

  tags = {
    Name = "${var.name}-nat-instance-${each.key}"
  }
}

##################################################
# Route Tables Public
##################################################

resource "aws_route_table" "public" {
  for_each = var.public_subnet_ids

  vpc_id = var.vpc_id

  tags = {
    Name = "${var.name}-rt-public-subnet-${each.key}"
  }
}

resource "aws_route_table_association" "public" {
  for_each = var.public_subnet_ids

  subnet_id      = each.value
  route_table_id = aws_route_table.public[each.key].id
}

resource "aws_route" "public_nat_instance" {
  for_each = var.public_subnet_ids

  route_table_id         = aws_route_table.public[each.key].id
  destination_cidr_block = "0.0.0.0/0"

  gateway_id = var.internet_gateway_id
}

##################################################
# Route Tables Private
##################################################

resource "aws_route_table" "private" {
  for_each = var.private_subnet_ids

  vpc_id = var.vpc_id

  tags = {
    Name = "${var.name}-rt-private-subnet-${each.key}"
  }
}

resource "aws_route_table_association" "private" {
  for_each = var.private_subnet_ids

  subnet_id      = each.value
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_route" "private_nat_instance" {
  for_each = var.private_subnet_ids

  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"

  network_interface_id = aws_instance.nat[
    local.nat_for_private[each.key]
  ].primary_network_interface_id
}
