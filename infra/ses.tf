module "ses" {
  source           = "./modules/terraform-aws-ses"
  domain           = "defdev.io"
  email_identities = ["inquiries@defdev.io"]
  iam_role_id      = aws_iam_role.lambda["emailer"].id
}