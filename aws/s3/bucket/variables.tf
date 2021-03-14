variable "bucket_name" {}

variable "policy" {
  default = ""
}

variable "acl" {
  default = "public-read"
}

variable "tags" {
  type    = map(string)
  default = {}
}
