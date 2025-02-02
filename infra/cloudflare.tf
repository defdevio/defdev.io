data "cloudflare_zone" "this" {
  name = "defdev.io"
}

resource "cloudflare_record" "www_defdev_io_acm_validation" {
  for_each = {
    for _, dvo in aws_acm_certificate.this.domain_validation_options :
    dvo.domain_name => dvo
  }

  content = each.value.resource_record_value
  name    = each.value.resource_record_name
  type    = each.value.resource_record_type
  zone_id = data.cloudflare_zone.this.id
  ttl     = 300
}

resource "cloudflare_record" "www_defdev_io_cloudfront_record" {
  content = module.cloudfront["www.defdev.io"].domain_name
  name    = "www"
  ttl     = 300
  type    = "CNAME"
  zone_id = data.cloudflare_zone.this.id
}