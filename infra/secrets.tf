module "secrets_manager" {
  source = "github.com/defdevio/terraform-aws-secrets-manager?ref=v1.0.0"

  allowed_principal_arns = [module.iam.role_arns["cloudflare_turnstile_validator"]]
  name                   = "cloudflare-turnstile-widget"

  secret_string = jsonencode({
    "site-key"   = module.cloudflare_resources.turnstile_widget_id
    "secret-key" = module.cloudflare_resources.turnstile_widget_secret
  })
}

moved {
  from = aws_secretsmanager_secret.cloudflare_turnstile_widget
  to   = module.secrets_manager.aws_secretsmanager_secret.this
}

moved {
  from = aws_secretsmanager_secret_policy.cloudflare_turnstile_widget
  to   = module.secrets_manager.aws_secretsmanager_secret_policy.this
}

moved {
  from = aws_secretsmanager_secret_version.cloudflare_turnstile_widget
  to   = module.secrets_manager.aws_secretsmanager_secret_version.this
}