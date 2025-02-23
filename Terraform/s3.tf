# Main bucket resource
resource "aws_s3_bucket" "my-blog" {
  bucket        = var.bucket_name
  force_destroy = true

  tags = {
    Name        = var.bucket_name
    Environment = terraform.workspace
    Project     = "BlogHosting"
  }
}