# Infrastructure
This directory contains the `terraform` code used to deploy all the underlying services required to properly
run the website. This includes `Lambda Functions`. Once that validates the `Contact Us` form and one that handles
generating the template and sending the email via `Simple Email Service`

We use `CloudFlare` for to host our DNS records which allows us to integrate with the `SES` service to fetch
its `DKIM` records to ensure that our domain is validated and able to securely send email.

We also build our `CloudFront` distribution which is used to cache the website in the `United States` and `Canada`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 5.84.0 |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | 4.51.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | 0.12.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.84.0 |
| <a name="provider_aws.east"></a> [aws.east](#provider\_aws.east) | 5.84.0 |
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | 4.51.0 |
| <a name="provider_time"></a> [time](#provider\_time) | 0.12.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_api_gateway"></a> [api\_gateway](#module\_api\_gateway) | ./modules/terraform-aws-api-gateway | n/a |
| <a name="module_cloudfront"></a> [cloudfront](#module\_cloudfront) | ./modules/terraform-aws-cloudfront | n/a |
| <a name="module_ecr"></a> [ecr](#module\_ecr) | ./modules/terraform-aws-ecr | n/a |
| <a name="module_lambda_functions"></a> [lambda\_functions](#module\_lambda\_functions) | ./modules/terraform-aws-lambda | n/a |
| <a name="module_s3"></a> [s3](#module\_s3) | ./modules/terraform-aws-s3 | n/a |
| <a name="module_ses"></a> [ses](#module\_ses) | ./modules/terraform-aws-ses | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.this](https://registry.terraform.io/providers/hashicorp/aws/5.84.0/docs/resources/acm_certificate) | resource |
| [aws_iam_role.lambda](https://registry.terraform.io/providers/hashicorp/aws/5.84.0/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.lambda_basic](https://registry.terraform.io/providers/hashicorp/aws/5.84.0/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_permission.cloudflare_validator](https://registry.terraform.io/providers/hashicorp/aws/5.84.0/docs/resources/lambda_permission) | resource |
| [aws_s3_bucket_policy.allow_cloudfront_origin](https://registry.terraform.io/providers/hashicorp/aws/5.84.0/docs/resources/s3_bucket_policy) | resource |
| [aws_secretsmanager_secret.cloudflare_turnstile_widget](https://registry.terraform.io/providers/hashicorp/aws/5.84.0/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_policy.cloudflare_turnstile_widget](https://registry.terraform.io/providers/hashicorp/aws/5.84.0/docs/resources/secretsmanager_secret_policy) | resource |
| [aws_secretsmanager_secret_version.cloudflare_turnstile_widget](https://registry.terraform.io/providers/hashicorp/aws/5.84.0/docs/resources/secretsmanager_secret_version) | resource |
| [cloudflare_record.ses_dkim_records](https://registry.terraform.io/providers/cloudflare/cloudflare/4.51.0/docs/resources/record) | resource |
| [cloudflare_record.ses_email_verification](https://registry.terraform.io/providers/cloudflare/cloudflare/4.51.0/docs/resources/record) | resource |
| [cloudflare_record.www_defdev_io_acm_validation](https://registry.terraform.io/providers/cloudflare/cloudflare/4.51.0/docs/resources/record) | resource |
| [cloudflare_record.www_defdev_io_cloudfront_record](https://registry.terraform.io/providers/cloudflare/cloudflare/4.51.0/docs/resources/record) | resource |
| [cloudflare_turnstile_widget.this](https://registry.terraform.io/providers/cloudflare/cloudflare/4.51.0/docs/resources/turnstile_widget) | resource |
| [time_sleep.wait_5_minutes](https://registry.terraform.io/providers/hashicorp/time/0.12.1/docs/resources/sleep) | resource |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/5.84.0/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.allow_cloudfront_origin](https://registry.terraform.io/providers/hashicorp/aws/5.84.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.allow_lambda](https://registry.terraform.io/providers/hashicorp/aws/5.84.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda](https://registry.terraform.io/providers/hashicorp/aws/5.84.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_ecr_pull](https://registry.terraform.io/providers/hashicorp/aws/5.84.0/docs/data-sources/iam_policy_document) | data source |
| [aws_region.this](https://registry.terraform.io/providers/hashicorp/aws/5.84.0/docs/data-sources/region) | data source |
| [aws_secretsmanager_secret.cloudflare](https://registry.terraform.io/providers/hashicorp/aws/5.84.0/docs/data-sources/secretsmanager_secret) | data source |
| [cloudflare_zone.this](https://registry.terraform.io/providers/cloudflare/cloudflare/4.51.0/docs/data-sources/zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_lambda_functions"></a> [lambda\_functions](#input\_lambda\_functions) | A map of Lambda Functions specs to deploy. | <pre>map(object({<br/>    spec = object({<br/>      description = string<br/>      timeout     = optional(number, 5)<br/>      ecr = object({<br/>        is_immutable = optional(bool, false)<br/>        image_tag    = string<br/>      })<br/>    })<br/>  }))</pre> | `{}` | no |
| <a name="input_s3_buckets"></a> [s3\_buckets](#input\_s3\_buckets) | A map of S3 bucket definitions to deploy. | <pre>map(object({<br/>    spec = object({<br/>      is_bucket_website   = optional(bool, false)<br/>      source_file_path    = optional(string, null)<br/>      source_file_pattern = optional(string, null)<br/><br/>      redirect_all_requests_to = optional(map(object({<br/>        protocol = string<br/>      })), {})<br/>    })<br/>  }))</pre> | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
