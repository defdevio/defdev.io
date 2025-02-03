resource "aws_secretsmanager_secret" "cloudflare_turnstile_widget" {
  name = "cloudflare-turnstile-widget"
}

resource "aws_secretsmanager_secret_version" "cloudflare_turnstile_widget" {
  secret_id = aws_secretsmanager_secret.cloudflare_turnstile_widget.id
  secret_string = jsonencode({
    "site-key"   = cloudflare_turnstile_widget.this.id
    "secret-key" = cloudflare_turnstile_widget.this.secret
  })
}