variable "name" {
  description = "Name of the VPC"
  type        = string
}

variable "engine" {
  description = "Database engine"
  type        = string
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
}

variable "username" {
  description = "Username for the master user"
  type        = string
}

variable "password" {
  description = "Username for the master user"
  type        = string
  sensitive   = true
}

variable "instance_class" {
  description = "Instance class for the database instance"
  type        = string

  validation {
    condition     = contains(["db.t4g.micro", "db.t4g.small", "db.t4g.medium"], var.instance_class)
    error_message = "Database instance class must be db.t4g.micro, db.t4g.small, or db.t4g.medium."
  }
}

variable "storage_type" {
  description = "DB storage type"
  type        = string
}

variable "allocated_storage" {
  description = "Allocated storage for the RDS instance"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs of the private subnets"
  type        = map(string)
}

variable "db_security_group_id" {
  description = "ID of database security group"
  type        = string
}
