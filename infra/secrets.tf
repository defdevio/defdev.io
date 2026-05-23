resource "aws_secretsmanager_secret" "cloudflare_turnstile_widget" {
  name = "cloudflare-turnstile-widget"
}

data "aws_iam_policy_document" "allow_lambda" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecret",
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      aws_secretsmanager_secret.cloudflare_turnstile_widget.arn
    ]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.lambda["cloudflare_turnstile_validator"].arn]
    }
  }
}

resource "aws_secretsmanager_secret_policy" "cloudflare_turnstile_widget" {
  secret_arn = aws_secretsmanager_secret.cloudflare_turnstile_widget.arn
  policy     = data.aws_iam_policy_document.allow_lambda.json
}

resource "aws_secretsmanager_secret_version" "cloudflare_turnstile_widget" {
  secret_id = aws_secretsmanager_secret.cloudflare_turnstile_widget.id
  secret_string = jsonencode({
    "site-key"   = cloudflare_turnstile_widget.this.id
    "secret-key" = cloudflare_turnstile_widget.this.secret
  })
}