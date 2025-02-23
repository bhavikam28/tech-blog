resource "aws_acm_certificate" "acm_certificate" {
  provider          = aws
  domain_name       = "technestbybhavika.com"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}