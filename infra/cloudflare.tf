resource "cloudflare_dns_record" "www_defdev_io_acm_validation" {
  for_each = {
    for _, dvo in aws_acm_certificate.this.domain_validation_options :
    dvo.domain_name => dvo
  }

  content = each.value.resource_record_value
  name    = each.value.resource_record_name
  ttl     = 300
  type    = each.value.resource_record_type
  zone_id = "41bd26725ef299b72663216ffa012106"
}

resource "cloudflare_dns_record" "www_defdev_io_cloudfront_record" {
  content = module.cloudfront["www.defdev.io"].domain_name
  name    = "www"
  ttl     = 300
  type    = "CNAME"
  zone_id = "41bd26725ef299b72663216ffa012106"
}

resource "cloudflare_dns_record" "ses_email_verification" {
  content = module.ses.domain_verification_token
  name    = "_amazonses.defdev.io"
  ttl     = 300
  type    = "TXT"
  zone_id = "41bd26725ef299b72663216ffa012106"
}

resource "cloudflare_dns_record" "ses_dkim_records" {
  count   = 3
  content = "${module.ses.domain_dkim_tokens[count.index]}.dkim.amazonses.com"
  name    = "${module.ses.domain_dkim_tokens[count.index]}._domainkey"
  ttl     = 300
  type    = "CNAME"
  zone_id = "41bd26725ef299b72663216ffa012106"
}

resource "cloudflare_turnstile_widget" "this" {
  account_id = jsondecode(data.aws_secretsmanager_secret_version.cloudflare.secret_string)["cloudflare_account_id"]
  domains    = ["defdev.io", "www.defdev.io", "localhost"]
  mode       = "managed"
  name       = "Contact us form protection widget"
  region     = "world"
}

moved {
  from = cloudflare_record.www_defdev_io_acm_validation
  to   = cloudflare_dns_record.www_defdev_io_acm_validation
}

moved {
  from = cloudflare_record.www_defdev_io_cloudfront_record
  to   = cloudflare_dns_record.www_defdev_io_cloudfront_record
}

moved {
  from = cloudflare_record.ses_email_verification
  to   = cloudflare_dns_record.ses_email_verification
}

moved {
  from = cloudflare_record.ses_dkim_records
  to   = cloudflare_dns_record.ses_dkim_records
}