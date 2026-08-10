resource "aws_db_subnet_group" "this" {
  name       = var.name
  subnet_ids = values(var.private_subnet_ids)

  tags = {
    Name = "${var.name}-db-subnet-group"
  }
}

resource "aws_db_instance" "this" {
  db_name                = var.name
  engine                 = var.engine
  engine_version         = var.engine_version
  username               = var.username
  password               = var.password
  instance_class         = var.instance_class
  storage_type           = var.storage_type
  allocated_storage      = var.allocated_storage
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.db_security_group_id]
  skip_final_snapshot    = true

  tags = {
    Name = "${var.name}-db"
  }
}

resource "aws_ssm_parameter" "db_engine" {
  name  = "/commitflow/db/engine"
  type  = "String"
  value = aws_db_instance.this.engine
}

resource "aws_ssm_parameter" "db_address" {
  name  = "/commitflow/db/address"
  type  = "String"
  value = aws_db_instance.this.address
}

resource "aws_ssm_parameter" "db_port" {
  name  = "/commitflow/db/port"
  type  = "String"
  value = aws_db_instance.this.port
}

resource "aws_ssm_parameter" "db_name" {
  name  = "/commitflow/db/name"
  type  = "String"
  value = aws_db_instance.this.db_name
}

resource "aws_ssm_parameter" "db_username" {
  name  = "/commitflow/db/username"
  type  = "String"
  value = aws_db_instance.this.username
}

resource "aws_ssm_parameter" "db_password" {
  name  = "/commitflow/db/password"
  type  = "SecureString"
  value = aws_db_instance.this.password
}

resource "aws_ssm_parameter" "db_url_commitflow" {
  name  = "/commitflow/db/url/commitflow"
  type  = "SecureString"
  value = "postgresql://${aws_db_instance.this.username}:${aws_db_instance.this.password}@${aws_db_instance.this.address}:${aws_db_instance.this.port}/commitflow"
}

resource "aws_ssm_parameter" "db_url_grafana" {
  name  = "/commitflow/db/url/grafana"
  type  = "SecureString"
  value = "postgres://${aws_db_instance.this.username}:${aws_db_instance.this.password}@${aws_db_instance.this.address}:${aws_db_instance.this.port}/grafana"
}
