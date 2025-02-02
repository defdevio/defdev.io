resource "aws_lambda_function" "this" {
  architectures                  = "arm64"
  function_name                  = var.function_name
  image_uri                      = var.image_uri
  package_type                   = "Image"
  reserved_concurrent_executions = var.concurrent_executions
  role                           = var.iam_role_arn
}