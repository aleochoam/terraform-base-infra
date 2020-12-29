
terraform {
  required_providers {
    aws = {
      source  = "-/aws"
      version = "~> 3.22"
    }
  }
  required_version = ">= 0.13"
}
