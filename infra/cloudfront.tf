# sleep for 5m to ensure that acm has had time to validate
# the certificate once the validation record has been created
# in cloudflare
resource "time_sleep" "wait_5_minutes" {
  create_duration = "5m"
  depends_on      = [cloudflare_record.www_defdev_io_acm_validation]
}

module "cloudfront" {
  for_each = { for k, v in var.s3_buckets : k => v if k == "www.defdev.io" }
  source   = "./modules/terraform-aws-cloudfront"

  acm_certificate_arn = aws_acm_certificate.this.arn
  aliases             = [each.key]
  origin_id           = each.key
  domain_name         = each.value.spec.is_bucket_website ? module.s3[each.key].bucket_website_endpoint : module.s3[each.key].bucket_regional_domain_name

  origin_access_control = {
    name        = each.key
    description = "Access control for ${each.key}"
    origin_type = "s3"
  }

  depends_on = [
    time_sleep.wait_5_minutes
  ]
}