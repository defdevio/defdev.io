module "iam" {
  source = "github.com/defdevio/terraform-aws-iam?ref=v1.1.0"

  account_id = local.aws_account_id

  roles = {
    for key in keys(var.lambda_functions) : key => {
      name = "lambda-execution-${replace(key, "_", "-")}"
    }
  }
}

moved {
  from = aws_iam_role.lambda
  to   = module.iam.aws_iam_role.this
}

moved {
  from = aws_iam_role_policy_attachment.lambda_basic
  to   = module.iam.aws_iam_role_policy_attachment.lambda_basic
}
