<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cognito_identity_pool.entraid](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_identity_pool) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_entraid_credentials_name"></a> [entraid\_credentials\_name](#input\_entraid\_credentials\_name) | n/a | `string` | `"AWS_Cognito_Identity_Pool"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cognito_pool_id"></a> [cognito\_pool\_id](#output\_cognito\_pool\_id) | n/a |
<!-- END_TF_DOCS -->
