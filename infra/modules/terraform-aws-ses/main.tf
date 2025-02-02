# domain identity
resource "aws_ses_domain_identity" "this" {
  count  = var.domain != null ? 1 : 0
  domain = var.domain
}

resource "aws_ses_domain_dkim" "this" {
  count  = var.domain != null ? 1 : 0
  domain = aws_ses_domain_identity.this[count.index].domain
}

# email identity
resource "aws_ses_email_identity" "this" {
  for_each = toset(var.email_identities)
  email    = each.value
}