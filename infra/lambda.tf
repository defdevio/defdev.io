data "aws_iam_policy_document" "lambda" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  for_each           = var.lambda_functions
  name               = "lambda-execution-${each.key}"
  assume_role_policy = data.aws_iam_policy_document.lambda.json
}

module "lambda_functions" {
  for_each = var.lambda_functions
  source   = "./modules/terraform-aws-lambda"

  concurrent_executions = -1
  function_name         = each.key
  iam_role_arn          = aws_iam_role.lambda[each.key].arn
  image_uri             = "${module.ecr[each.key].repo_url}:${each.value.spec.ecr.image_tag}"
}