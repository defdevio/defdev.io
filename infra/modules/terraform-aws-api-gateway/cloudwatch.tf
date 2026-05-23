resource "aws_cloudwatch_log_group" "lambda_proxy" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.lambda_proxy.id}/${var.lambda_proxy_stage_name}"
  retention_in_days = 7
}

data "aws_iam_policy_document" "cloudwatch_apigw" {
  statement {
    actions = ["sts:AssumeRole"]
    sid     = "AllowApiGatewayToCloudWatchLogs"
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cloudwatch_apigw" {
  name               = "api-gateway-logs-role"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_apigw.json
}

resource "aws_iam_role_policy_attachment" "cloudwatch_apigw" {
  role       = aws_iam_role.cloudwatch_apigw.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_api_gateway_account" "cloudwatch_apigw" {
  cloudwatch_role_arn = aws_iam_role.cloudwatch_apigw.arn
}