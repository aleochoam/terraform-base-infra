# VPC Variables
variable "public_subnets" {
  type = list(string)

  default = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "dbs_private_subnets" {
  type = list(string)

  default = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "ssh_cidr" {
  default = "0.0.0.0/0"
}

variable "aws_azs" {
  type = list(string)

  default = ["us-east-1a", "us-east-1b"]
}

# RDS Variables
variable "rds_db_name" {
}

variable "rds_username" {
}

variable "rds_password" {
}

variable "rds_engine" {
  default = "postgres"
}

variable "rds_engine_version" {
  default = "12.4"
}

variable "rds_port" {
  default = "5432"
}

variable "rds_multi_az" {
  default = false
}

variable "rds_instance_type" {
  default = "db.t2.micro"
}

variable "rds_backup_retention_period" {
  type        = number
  description = "Number of days of database backups"
  default     = 7
}

# EB Variables
variable "eb_application" {
}

variable "eb_environment" {
}

variable "eb_ec2_key_name" {
}

variable "eb_solution_stack_name" {
  default = "64bit Amazon Linux 2018.03 v2.10.0 running Docker 17.12.1-ce"
}

variable "eb_environment_type" {
  default = "SingleInstance"
}

variable "eb_instance_type" {
  default = "t3.small"
}

variable "eb_stream_logs" {
  default = "false"
}

variable "eb_env_vars" {
  default = []
  type = list(object({
    name  = string,
    value = string
  }))
}
