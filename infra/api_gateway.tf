module "api_gateway" {
  for_each = { for k, v in var.lambda_functions : k => v if k == "cloudflare_turnstile_validator" }
  source   = "./modules/terraform-aws-api-gateway"

  aws_account_id             = local.aws_account_id
  aws_region                 = local.aws_region
  lambda_function_name       = module.lambda_functions["cloudflare_turnstile_validator"].function_name
  lambda_proxy_name          = module.lambda_functions["cloudflare_turnstile_validator"].function_name
  lambda_proxy_stage_name    = "prod"
  lambda_function_invoke_arn = module.lambda_functions["cloudflare_turnstile_validator"].function_invoke_arn
}