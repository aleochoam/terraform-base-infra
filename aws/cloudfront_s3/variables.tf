# Indicates if the module will be used for assets of for a website
variable "is_website" {}

# Bucket variables
variable "bucket_name" {}

variable "index_document" {
  default = "index.html"
}

# Cloudfront variables
variable "cf_certificate_domain" {
  default = ""
}

variable "cf_enabled" {
  default = true
}

variable "cf_aliases" {
  default = []
}

variable "cf_allowed_methods" {
  default = ["GET", "HEAD"]
}

variable "cf_cached_methods" {
  default = ["GET", "HEAD"]
}

variable "cf_forward_query_string" {
  default = true
}

variable "cf_forward_cookies" {
  default = "none"
}

variable "cf_viewer_protocol_policy" {
  default = "redirect-to-https"
}

variable "cf_compress" {
  default = true
}

variable "cf_cache_policy" {
  default = "CachingOptimized"
}

variable "cf_request_policy" {
  default = "CORS-S3Origin"
}
