data "aws_acm_certificate" "c" {
  count  = var.cf_certificate_domain == "" ? 0 : 1
  domain = var.cf_certificate_domain
}

data "aws_cloudfront_origin_request_policy" "request_policy" {
  name = "Managed-CORS-S3Origin"
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "${var.bucket_name} OAI"
}

module "bucket" {
  source = "../s3/bucket"

  bucket_name = var.bucket_name
  acl         = "private"
  policy      = null
  cors        = !var.is_website
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

resource "aws_s3_bucket_policy" "policy" {
  bucket = module.bucket.bucket_id
  policy = data.aws_iam_policy_document.s3_policy.json
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = module.bucket.bucket_regional_domain_name
    origin_id   = local.origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  // SPA Websites need custom error response to redirect any path to the index.html
  // Assets distribution does not need any custom response
  dynamic "custom_error_response" {
    for_each = var.is_website ? [404, 403] : []

    content {
      error_code         = custom_error_response.value
      response_page_path = "/index.html"
      response_code      = 200
    }
  }

  enabled             = var.cf_enabled
  is_ipv6_enabled     = true
  default_root_object = var.is_website ? var.index_document : null

  aliases = var.cf_aliases

  default_cache_behavior {
    allowed_methods  = var.cf_allowed_methods
    cached_methods   = var.cf_cached_methods
    target_origin_id = local.origin_id

    cache_policy_id          = local.cache_policies[var.cf_cache_policy]
    origin_request_policy_id = local.request_policy

    viewer_protocol_policy = var.cf_viewer_protocol_policy
    compress               = var.cf_compress
  }

  viewer_certificate {
    cloudfront_default_certificate = !local.custom_certificate

    acm_certificate_arn      = local.custom_certificate ? data.aws_acm_certificate.c[0].arn : ""
    minimum_protocol_version = local.custom_certificate ? "TLSv1.2_2021" : "TLSv1"
    ssl_support_method       = local.custom_certificate ? "sni-only" : ""
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
