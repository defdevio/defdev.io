module "lambda_functions" {
  for_each = var.lambda_functions
  source   = "./modules/terraform-aws-lambda"

  concurrent_executions = -1
  description           = each.value.spec.description
  function_name         = each.key
  iam_role_arn          = aws_iam_role.lambda[each.key].arn
  image_uri             = "${module.ecr[each.key].repo_url}:${each.value.spec.ecr.image_tag}"
  timeout               = each.value.spec.timeout
}