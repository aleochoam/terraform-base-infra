locals {
  origin_id          = "S3-Origin"
  custom_certificate = var.cf_certificate_domain == "" ? false : true

  cache_policies = {
    CachingOptimized = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    CachingDisabled  = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
  }

  request_policies = {
    CORS-S3Origin           = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf"
    UserAgentRefererHeaders = "acba4595-bd28-49b8-b9fe-13317c0390fa"
  }

  spa_request_policy = data.aws_cloudfront_origin_request_policy.request_policy.id
  request_policy     = !var.is_website ? local.request_policies[var.cf_request_policy] : local.spa_request_policy
}
