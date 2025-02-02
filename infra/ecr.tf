data "aws_iam_policy_document" "lambda_ecr_pull" {
  statement {
    effect = "Allow"

    actions = [
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
    ]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    dynamic "condition" {
      for_each = var.lambda_functions
      content {
        test     = "StringLike"
        values   = ["arn:aws:lambda:${local.aws_region}:${local.aws_account_id}:function:${condition.key}"]
        variable = "aws:SourceARN"
      }
    }
  }
}

module "ecr" {
  for_each = var.lambda_functions
  source   = "./modules/terraform-aws-ecr"

  name                 = "defdevio/lambda-${each.key}"
  is_immutable         = each.value.spec.ecr.is_immutable
  repo_policy_document = data.aws_iam_policy_document.lambda_ecr_pull.json
}