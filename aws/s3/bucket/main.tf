resource "aws_s3_bucket" "bucket" {
  bucket        = var.bucket_name
  acl           = var.acl
  policy        = var.policy
  force_destroy = true

  dynamic "cors_rule" {
    for_each = var.cors ? [1] : []

    content {
      allowed_headers = []
      allowed_methods = [
        "GET"
      ]
      allowed_origins = [
        "*"
      ]
      expose_headers  = []
      max_age_seconds = 0
    }
  }
}
