output "s3_bucket" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.my-blog.bucket
}

output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.s3_distribution.id
}

output "route53_zone_id" {
  description = "The ID of the Route 53 hosted zone"
  value       = aws_route53_zone.primary.zone_id
}