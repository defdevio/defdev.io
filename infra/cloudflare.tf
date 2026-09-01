module "cloudflare_resources" {
  source = "github.com/defdevio/terraform-cloudflare-resources?ref=v1.0.2"

  acm_domain_validation_options = module.acm.domain_validation_options
  ses_domain_dkim_tokens        = module.ses.domain_dkim_tokens
  ses_domain_verification_token = module.ses.domain_verification_token
  turnstile_account_id          = jsondecode(data.aws_secretsmanager_secret_version.cloudflare.secret_string)["cloudflare_account_id"]
  turnstile_domains             = ["defdev.io", "www.defdev.io", "localhost"]
  zone_id                       = "41bd26725ef299b72663216ffa012106"
}

moved {
  from = cloudflare_record.www_defdev_io_acm_validation
  to   = cloudflare_dns_record.www_defdev_io_acm_validation
}

moved {
  from = cloudflare_record.apex_defdev_io_www_record
  to   = cloudflare_dns_record.apex_defdev_io_www_record
}

moved {
  from = cloudflare_record.ses_email_verification
  to   = cloudflare_dns_record.ses_email_verification
}

moved {
  from = cloudflare_record.ses_dkim_records
  to   = cloudflare_dns_record.ses_dkim_records
}

moved {
  from = cloudflare_dns_record.www_defdev_io_acm_validation
  to   = module.cloudflare_resources.cloudflare_dns_record.acm_validation
}

moved {
  from = cloudflare_dns_record.apex_defdev_io_www_record
  to   = module.cloudflare_resources.cloudflare_dns_record.apex_www
}

moved {
  from = cloudflare_ruleset.apex_to_www_redirect
  to   = module.cloudflare_resources.cloudflare_ruleset.apex_to_www_redirect
}

moved {
  from = cloudflare_dns_record.ses_email_verification
  to   = module.cloudflare_resources.cloudflare_dns_record.ses_email_verification
}

moved {
  from = cloudflare_dns_record.ses_dkim_records
  to   = module.cloudflare_resources.cloudflare_dns_record.ses_dkim
}

moved {
  from = cloudflare_turnstile_widget.this
  to   = module.cloudflare_resources.cloudflare_turnstile_widget.this
}