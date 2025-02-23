locals {
  # Unique origin ID for S3 bucket
  s3_origin_id = "${var.bucket_name}-origin"

  # Use the S3 bucket's regional domain name (CloudFront compatible)
  s3_domain_name = aws_s3_bucket.my-blog.bucket_regional_domain_name
}