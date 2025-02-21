# Primary AWS Region
variable "primary_region" {
  description = "The primary AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

# Secondary AWS Region
variable "secondary_region" {
  description = "The secondary AWS region (e.g., for ACM or disaster recovery)"
  type        = string
  default     = "eu-west-1"
}

variable "aws_role_arn" {
  description = "The ARN of the IAM role to assume"
  type        = string
}

variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "custom_domain" {
  description = "The custom domain for the CloudFront distribution"
  type        = string
}

variable "acm_certificate_arn" {
  description = "The ARN of the ACM certificate for HTTPS"
  type        = string
}

variable "domain_name" {
  description = "The domain name for the Route 53 hosted zone"
  type        = string
}