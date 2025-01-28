resource "aws_cloudfront_origin_access_control" "this" {
  name                              = var.origin_access_control.name
  description                       = var.origin_access_control.description
  origin_access_control_origin_type = var.origin_access_control.origin_type
  signing_behavior                  = var.origin_access_control.signing_behavior
  signing_protocol                  = var.origin_access_control.signing_protocol
}