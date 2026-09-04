module "lambda_functions" {
  for_each = var.lambda_functions
  source   = "github.com/defdevio/terraform-aws-lambda?ref=v1.0.0"

  concurrent_executions = -1
  description           = each.value.spec.description
  function_name         = replace(each.key, "_", "-")
  iam_role_arn          = module.iam.role_arns[each.key]
  image_uri             = "${module.ecr[each.key].repo_url}:${each.value.spec.ecr.image_tag}"
  timeout               = each.value.spec.timeout
}

resource "aws_lambda_permission" "cloudflare_validator" {
  statement_id  = "AllowExecutionFromCloudFlareValidator"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_functions["emailer"].function_name
  principal     = module.iam.role_arns["cloudflare_turnstile_validator"]
}