# Terraform Provider Block
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 6.0"
    }
  }

  # Remote Backend Configuration
  backend "remote" {
    hostname     = "app.terraform.io"  # Terraform Cloud's hostname
    organization = "cloud-talents"     # Your Terraform Cloud organization name

    workspaces {
      name = "tech-blog"              # Your Terraform Cloud workspace name
    }
  }
}


# Create the S3 bucket
resource "aws_s3_bucket" "my-blog" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Environment = terraform.workspace
    Project     = "Blog Hosting"
  }
}

# Configure the S3 bucket website
resource "aws_s3_bucket_website_configuration" "my-blog" {
  bucket = aws_s3_bucket.my-blog.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Cloudfront Distribution
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.my-blog.bucket_regional_domain_name
    origin_id   = "S3-${var.bucket_name}"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = [var.custom_domain]

  viewer_certificate {
    acm_certificate_arn = var.acm_certificate_arn
    ssl_support_method  = "sni-only"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.bucket_name}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

# Route 53 Hosted Zone
resource "aws_route53_zone" "primary" {
  name = var.domain_name
}

# Route 53 Record for CloudFront
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}