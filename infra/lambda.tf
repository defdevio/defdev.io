module "lambda_functions" {
  for_each = var.lambda_functions
  source   = "./modules/terraform-aws-lambda"

  concurrent_executions = -1
  description           = each.value.spec.description
  function_name         = replace(each.key, "_", "-")
  iam_role_arn          = aws_iam_role.lambda[each.key].arn
  image_uri             = "${module.ecr[each.key].repo_url}:${each.value.spec.ecr.image_tag}"
  timeout               = each.value.spec.timeout
}

resource "aws_lambda_permission" "cloudflare_validator" {
  statement_id  = "AllowExecutionFromCloudFlareValidator"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_functions["emailer"].function_name
  principal     = aws_iam_role.lambda["cloudflare_turnstile_validator"].arn
}