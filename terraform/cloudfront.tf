module "cloudfrount" {
  for_each = var.s3_buckets
  source   = "./modules/terraform-aws-cloudfront"

  acm_certificate_arn = aws_acm_certificate.this.arn
  aliases             = [each.key]
  origin_id           = each.key
  domain_name         = each.value.is_bucket_website ? module.s3[each.key].bucket_website_endpoint : module.s3[each.key].bucket_regional_domain_name

  origin_access_control = {
    name        = each.key
    description = "Access control for ${each.key}"
    origin_type = "s3"
  }
}