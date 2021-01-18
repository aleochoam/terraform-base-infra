variable "environment" {}
variable "application" {}
variable "db_name" {}
variable "username" {}
variable "password" {}
variable "security_group" {}
variable "engine" {}
variable "engine_version" {}

variable "allocated_storage" {
  default = 20
}
variable "azs" {
  type = list(string)
}

variable "subnets" {
  type = list(string)
}

variable "instance_type" {
  default = "db.t2.micro"
}

variable "multi_az" {
  default = false
}

variable "backup_retention_period" {
  type        = number
  description = "Number of days of backups"
  default     = 7
}
