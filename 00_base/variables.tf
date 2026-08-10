variable "db_password" {
  type      = string
  sensitive = true
}

variable "github_pat" {
  type      = string
  sensitive = true
}

variable "gitlab_pat" {
  type      = string
  sensitive = true
}

variable "grafana_username" {
  type    = string
  default = "ntomic"
}

variable "grafana_password" {
  type      = string
  sensitive = true
}
