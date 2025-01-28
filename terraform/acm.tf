resource "aws_acm_certificate" "this" {
  provider          = aws.east
  domain_name       = "*.defdev.io"
  key_algorithm     = "RSA_2048"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}