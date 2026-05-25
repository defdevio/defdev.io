# terraform-aws-cloudfront

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.84 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.84 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudfront_distribution.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_function.url_rewrite](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_function) | resource |
| [aws_cloudfront_origin_access_control.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_control) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acm_certificate_arn"></a> [acm\_certificate\_arn](#input\_acm\_certificate\_arn) | n/a | `string` | n/a | yes |
| <a name="input_aliases"></a> [aliases](#input\_aliases) | n/a | `list(string)` | `[]` | no |
| <a name="input_default_root_object"></a> [default\_root\_object](#input\_default\_root\_object) | n/a | `string` | `"index.html"` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | n/a | `string` | n/a | yes |
| <a name="input_origin_access_control"></a> [origin\_access\_control](#input\_origin\_access\_control) | n/a | <pre>object({<br/>    name             = string<br/>    description      = string<br/>    origin_type      = string<br/>    signing_behavior = optional(string, "always")<br/>    signing_protocol = optional(string, "sigv4")<br/>  })</pre> | `null` | no |
| <a name="input_origin_id"></a> [origin\_id](#input\_origin\_id) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | n/a |
| <a name="output_domain_name"></a> [domain\_name](#output\_domain\_name) | n/a |
| <a name="output_id"></a> [id](#output\_id) | n/a |
<!-- END_TF_DOCS -->
