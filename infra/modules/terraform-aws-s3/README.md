# terraform-aws-s3

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
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_website_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration) | resource |
| [aws_s3_object.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | The name of the bucket. | `string` | n/a | yes |
| <a name="input_bucket_website_error_document_key"></a> [bucket\_website\_error\_document\_key](#input\_bucket\_website\_error\_document\_key) | n/a | `string` | `null` | no |
| <a name="input_bucket_website_index_document_suffix"></a> [bucket\_website\_index\_document\_suffix](#input\_bucket\_website\_index\_document\_suffix) | n/a | `string` | `null` | no |
| <a name="input_bucket_website_redirect_all_requests"></a> [bucket\_website\_redirect\_all\_requests](#input\_bucket\_website\_redirect\_all\_requests) | n/a | <pre>map(object({<br/>    protocol = string<br/>  }))</pre> | `{}` | no |
| <a name="input_is_bucket_website"></a> [is\_bucket\_website](#input\_is\_bucket\_website) | n/a | `bool` | `false` | no |
| <a name="input_source_file_path"></a> [source\_file\_path](#input\_source\_file\_path) | n/a | `string` | `null` | no |
| <a name="input_source_file_pattern"></a> [source\_file\_pattern](#input\_source\_file\_pattern) | The file source pattern to target the files for upload. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags to apply to the bucket. | `map(string)` | <pre>{<br/>  "owner": "defdev.io"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | n/a |
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | n/a |
| <a name="output_bucket_regional_domain_name"></a> [bucket\_regional\_domain\_name](#output\_bucket\_regional\_domain\_name) | n/a |
| <a name="output_bucket_website_endpoint"></a> [bucket\_website\_endpoint](#output\_bucket\_website\_endpoint) | n/a |
<!-- END_TF_DOCS -->
