# Primary AWS Region
variable "region" {
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

# S3 Bucket Name
variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
  default     = "technestbybhavika.com"
  validation {
    condition     = length(var.bucket_name) > 3 && length(var.bucket_name) <= 63 && can(regex("^[a-z0-9.-]+$", var.bucket_name))
    error_message = "S3 bucket name must be 3-63 characters long and contain only lowercase letters, numbers, hyphens, or periods."
  }
}

# CloudFront Aliases
variable "cloudfront_aliases" {
  description = "Custom domain names for the CloudFront distribution (leave empty if not using custom domain)"
  type        = list(string)
  default     = [] # Leave empty for no custom domain
}

# Tags
variable "tags" {
  type        = map(string)
  description = "Default tags for resources"
  default     = {}
}