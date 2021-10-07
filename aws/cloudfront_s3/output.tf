output "bucket_id" {
  value = module.bucket.bucket_id
}

output "bucket_arn" {
  value = module.bucket.bucket_arn
}

output "bucket_domain_name" {
  value = module.bucket.bucket_domain_name
}

output "bucket_regional_domain_name" {
  value = module.bucket.bucket_regional_domain_name
}

output "cf_id" {
  value = aws_cloudfront_distribution.s3_distribution.id
}

output "cf_domain_name" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}

output "cf_hosted_zone_id" {
  value = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
}
