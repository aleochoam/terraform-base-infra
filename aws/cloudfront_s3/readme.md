## Usage example

### For an assets distribution

```hcl
provider "aws" {
  # You can specify an access_key and a secret_key instead of an AWS profile
  # access_key = "XXXXXXXXXX"
  # secret_key = "XXXXXXXXXX"
  profile = "eb-cli"
  region  = "eu-west-1"
}

# Create the bucket with assets configuration
module "assets" {
  source = "git@github.com:aleochoam/terraform-base-infra.git//aws/cloudfront_website"

  bucket_name = "test-bucket"

  is_website            = false
  cf_certificate_domain = "*.example.com"
  cf_aliases            = [assets.example.com]
  cf_allowed_methods    = ["GET", "HEAD"]
  cf_cached_methods     = ["GET", "HEAD"]
  cf_cache_policy       = "CachingOptimized"
  cf_request_policy     = "CORS-S3Origin"
}
```

### For a webpage distribution
```hcl
module "web" {
  source = "git@github.com:aleochoam/terraform-base-infra.git//aws/cloudfront_website"

  is_website     = true
  bucket_name    = "test-web-bucket"
  index_document = "index.html"

  cf_certificate_domain = "*.example.com"
  cf_enabled            = true
  cf_aliases            = [www.example.com]
  cf_allowed_methods    = ["GET", "HEAD"]
  cf_cached_methods     = ["GET", "HEAD"]
  cf_cache_policy       = "CachingOptimized"
}
```
