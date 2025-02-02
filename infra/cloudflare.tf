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

resource "cloudflare_record" "ses_email_verification" {
  content = module.ses.domain_verification_token
  name    = "_amazonses.defdev.io"
  ttl     = 300
  type    = "TXT"
  zone_id = data.cloudflare_zone.this.id
}

resource "cloudflare_record" "ses_dkim_records" {
  count   = 3
  content = "${module.ses.domain_dkim_tokens[count.index]}.dkim.amazonses.com"
  name    = "${module.ses.domain_dkim_tokens[count.index]}._domainkey"
  ttl     = 300
  type    = "CNAME"
  zone_id = data.cloudflare_zone.this.id
}
