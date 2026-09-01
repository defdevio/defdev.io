module "cloudfront" {
  for_each = { for k, v in var.s3_buckets : k => v if k == "www.defdev.io" }
  source   = "github.com/defdevio/terraform-aws-cloudfront?ref=v1.0.1"

  acm_certificate_arn = module.acm.arn
  aliases             = [each.key]
  cloudflare_zone_id  = "41bd26725ef299b72663216ffa012106"
  origin_id           = each.key
  domain_name         = each.value.spec.is_bucket_website ? module.s3[each.key].bucket_website_endpoint : module.s3[each.key].bucket_regional_domain_name

  origin_access_control = {
    name        = each.key
    description = "Access control for ${each.key}"
    origin_type = "s3"
  }

  depends_on = [
    module.cloudflare_resources
  ]
}

moved {
  from = time_sleep.wait_5_minutes
  to   = module.cloudflare_resources.time_sleep.wait_5_minutes
}

moved {
  from = cloudflare_record.www_defdev_io_cloudfront_record
  to   = cloudflare_dns_record.www_defdev_io_cloudfront_record
}

moved {
  from = cloudflare_dns_record.www_defdev_io_cloudfront_record
  to   = module.cloudfront["www.defdev.io"].cloudflare_dns_record.www
}