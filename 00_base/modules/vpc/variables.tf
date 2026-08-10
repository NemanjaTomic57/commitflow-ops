variable "name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type = map(object({
    cidr = string
    az   = string
  }))
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type = map(object({
    cidr = string
    az   = string
  }))
}
