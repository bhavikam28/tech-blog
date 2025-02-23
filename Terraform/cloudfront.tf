#Cloudfront Funtion to Append Index.html to URLs
resource "aws_cloudfront_function" "append_index_html" {
  name    = "${var.bucket_name}-append-index"
  runtime = "cloudfront-js-2.0"
  comment = "Appends index.html to URLs"
  publish = true
  code    = file("functions/append-index-html.js")
}

# Define CloudFront Origin Access Control (OAC) for secure S3 access
resource "aws_cloudfront_origin_access_control" "default" {
  name                              = "${var.bucket_name}-OAC"
  description                       = "OAC for S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Define CloudFront Distribution
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.my-blog.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
    origin_id                = local.s3_origin_id
  }
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for S3 bucket"
  default_root_object = "index.html"

  # Add custom domain
  aliases = ["technestbybhavika.com"]

  custom_error_response {
    error_code            = 403
    response_page_path    = "/404.html"
    response_code         = 404
    error_caching_min_ttl = 10
  }

  custom_error_response {
    error_code            = 404
    response_page_path    = "/404.html"
    response_code         = 404
    error_caching_min_ttl = 10
  }

  custom_error_response {
    error_code            = 500
    response_page_path    = "/404.html"
    response_code         = 500
    error_caching_min_ttl = 10
  }

  viewer_certificate {
    acm_certificate_arn      = "arn:aws:acm:us-east-1:390402540832:certificate/cc8427c0-acf3-4ef8-bc3e-af9c94b82604"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  # Default Cache behavior
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT", "DELETE"] # Fully valid
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6" # AWS Managed Caching Policy
    compress        = true

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.append_index_html.arn
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Geo-restrictions (optional)
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

# S3 Bucket Policy to Allow CloudFront Access
resource "aws_s3_bucket_policy" "CF_S3_Policy" {
  bucket = aws_s3_bucket.my-blog.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "arn:aws:s3:::${aws_s3_bucket.my-blog.bucket}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.s3_distribution.id}"
          }
        }
      }
    ]
  })
}