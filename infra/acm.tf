module "acm" {
  source = "github.com/defdevio/terraform-aws-acm?ref=v1.0.0"

  domain_name = "*.defdev.io"

  providers = {
    aws = aws.east
  }
}

moved {
  from = aws_acm_certificate.this
  to   = module.acm.aws_acm_certificate.this
}
