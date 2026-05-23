# terraform-aws-ecr

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
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
| [aws_ecr_repository.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_encryption_type"></a> [encryption\_type](#input\_encryption\_type) | n/a | `string` | `"AES256"` | no |
| <a name="input_is_immutable"></a> [is\_immutable](#input\_is\_immutable) | n/a | `bool` | `false` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | n/a | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | n/a | yes |
| <a name="input_repo_policy_document"></a> [repo\_policy\_document](#input\_repo\_policy\_document) | n/a | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_repo_arn"></a> [repo\_arn](#output\_repo\_arn) | n/a |
| <a name="output_repo_url"></a> [repo\_url](#output\_repo\_url) | n/a |
<!-- END_TF_DOCS -->
