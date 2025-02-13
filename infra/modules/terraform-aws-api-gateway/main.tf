locals {
  log_format = {
    requestId         = "$context.requestId"
    extendedRequestId = "$context.extendedRequestId"
    ip                = "$context.identity.sourceIp"
    caller            = "$context.identity.caller"
    user              = "$context.identity.user"
    requestTime       = "$context.requestTime"
    httpMethod        = "$context.httpMethod"
    resourcePath      = "$context.resourcePath"
    status            = "$context.status"
    protocol          = "$context.protocol"
    responseLength    = "$context.responseLength"
    authError         = "$context.authorize.error"
    errorMessage      = "$context.error.message"
  }
}

resource "aws_api_gateway_rest_api" "lambda_proxy" {
  name = var.lambda_proxy_name

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "lambda_proxy" {
  path_part   = "{proxy+}"
  parent_id   = aws_api_gateway_rest_api.lambda_proxy.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.lambda_proxy.id
}

resource "aws_api_gateway_method" "lambda_proxy" {
  rest_api_id   = aws_api_gateway_rest_api.lambda_proxy.id
  resource_id   = aws_api_gateway_resource.lambda_proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_proxy" {
  rest_api_id             = aws_api_gateway_rest_api.lambda_proxy.id
  resource_id             = aws_api_gateway_resource.lambda_proxy.id
  http_method             = aws_api_gateway_method.lambda_proxy.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_function_invoke_arn
}

resource "aws_lambda_permission" "lambda_proxy" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws_region}:${var.aws_account_id}:${aws_api_gateway_rest_api.lambda_proxy.id}/prod/*"
}

resource "aws_api_gateway_deployment" "lambda_proxy" {
  rest_api_id = aws_api_gateway_rest_api.lambda_proxy.id
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "lambda_proxy" {
  deployment_id = aws_api_gateway_deployment.lambda_proxy.id
  rest_api_id   = aws_api_gateway_rest_api.lambda_proxy.id
  stage_name    = var.lambda_proxy_stage_name

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.lambda_proxy.arn
    format          = jsonencode(local.log_format)
  }

  lifecycle {
    ignore_changes = [deployment_id]
  }

  depends_on = [
    aws_api_gateway_account.cloudwatch_apigw
  ]
}