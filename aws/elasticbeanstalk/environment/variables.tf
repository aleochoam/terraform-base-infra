variable "environment" {
}

variable "vpc_id" {
}

variable "ec2_key_name" {
}

variable "application" {
}

variable "security_group" {
}

variable "rds_connection_url" {
}

variable "subnets" {
  type = list(string)
}

variable "solution_stack_name" {
  default = "64bit Amazon Linux 2017.09 v2.8.4 running Docker 17.09.1-ce"
}

variable "environment_type" {
  default = "SingleInstance"
}

variable "instance_type" {
  default = "t3.small"
}

variable "stream_logs" {
  default = "false"
}

variable "load_balancer_type" {
  default = "classic"
}

