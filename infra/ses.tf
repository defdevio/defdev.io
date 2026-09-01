module "ses" {
  source           = "github.com/defdevio/terraform-aws-ses?ref=v1.0.0"
  domain           = "defdev.io"
  email_identities = ["inquiries@defdev.io"]
  iam_role_id      = module.iam.role_ids["emailer"]
}