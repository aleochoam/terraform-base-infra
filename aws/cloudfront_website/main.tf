locals {
  origin_id          = "S3-Origin"
  custom_certificate = var.cf_certificate_domain == "" ? false : true
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "${var.bucket_name} OAI"
}

module "bucket" {
  source = "../s3/bucket"

  bucket_name = var.bucket_name
  acl         = "private"
  policy      = null
  tags        = var.tags
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${module.bucket.bucket_arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
  }
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = module.bucket.bucket_regional_domain_name
    origin_id   = local.origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  custom_error_response {
    error_code         = 404
    response_page_path = "/index.html"
    response_code      = 200
  }

  enabled             = var.cf_enabled
  is_ipv6_enabled     = true
  default_root_object = var.bucket_index_document

  aliases = var.cf_aliases

  default_cache_behavior {
    allowed_methods  = var.cf_allowed_methods
    cached_methods   = var.cf_cached_methods
    target_origin_id = local.origin_id

    forwarded_values {
      query_string = var.cf_forward_query_string

      cookies {
        forward = var.cf_forward_cookies
      }
    }

    viewer_protocol_policy = var.cf_viewer_protocol_policy
    min_ttl                = var.cf_min_ttl
    default_ttl            = var.cf_default_ttl
    max_ttl                = var.cf_max_ttl
    compress               = var.cf_compress
  }

  viewer_certificate {
    cloudfront_default_certificate = ! local.custom_certificate

    acm_certificate_arn      = local.custom_certificate ? element(concat(data.aws_acm_certificate.c.*.arn, list("")), 0) : ""
    minimum_protocol_version = local.custom_certificate ? "TLSv1.2_2019" : "TLSv1"
    ssl_support_method       = local.custom_certificate ? "sni-only" : ""
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = var.tags
}
