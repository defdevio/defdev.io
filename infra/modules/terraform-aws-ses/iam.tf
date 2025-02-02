data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"
    actions = [
      "ses:SendEmail",
      "ses:SendRawEmail",
    ]
    resources = concat([try(aws_ses_domain_identity.this[0].arn, null)], [
      for _, email in aws_ses_email_identity.this :
      email.arn
    ])
  }
}

resource "aws_iam_policy" "this" {
  name   = "allow-ses-access-to-${var.domain}"
  policy = data.aws_iam_policy_document.this.json
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = var.iam_role_id
  policy_arn = aws_iam_policy.this.arn
}