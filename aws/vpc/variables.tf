variable "application" {}
variable "environment" {}

variable "azs" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "dbs_private_subnets" {
  type = list(string)
}

variable "cidr_block" {
  default = "10.0.0.0/16"
}

variable "db_port" {
  default = "5432"
}

variable "ssh_cidr" {
  default = "0.0.0.0/0"
}
