resource "aws_s3_bucket" "s3bucket" {
  bucket = var.bucket_name
  acl    = "private"
}

resource "aws_cloudfront_origin_access_identity" "example" {}


resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.s3bucket.bucket_domain_name
    origin_id   = "S3-${aws_s3_bucket.s3bucket.bucket}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.example.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.s3bucket.bucket}"
    cache_policy_id  = var.cache_policy_id
    viewer_protocol_policy = "allow-all"
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}