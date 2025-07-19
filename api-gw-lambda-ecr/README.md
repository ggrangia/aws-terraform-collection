This project shows a setup with API Gateway defined through OpenAPI specification (with aws extensions)
invoking lambdas using containers

## Description

This project is organized as follows:

- 2 ECR repositories
- 2 lambda functions (1 API, 1 authorizer) using containers
- 1 API Gateway defined using OpenAPI yml specification and terraform templating (1 API and 1 request authorizer)
- Codedeploy to manage the lambda alias updates

The main goal of this project is to create an API Gateway entirely using OpenAPI yml.
To achieve this goal I used a terraform template (.tpl) and injected the lambdas invoke arns and roles via variables.
The API lambda has an alias that gets updated when a specific tag (v\*) gets pushed to the ECR repository.
An eventbridge rule catches the event and forwards it to a lambda function that publishes a new lambda version,
creates a new alias with the (escaped) tag name, and triggers codedeploy to update the alias with the initial alias to the last version.
The alias created by the lambda function is kept as a reference.
In this example I used terraform docker provider, but it is totally possible to use github actions to create and push the containers.

![Arch diagram](/api-gw-lambda-ecr/img/aws_terraform_collection_apigw_ecr.jpg)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |
| <a name="requirement_docker"></a> [docker](#requirement\_docker) | 3.6.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.4.0 |
| <a name="provider_docker"></a> [docker](#provider\_docker) | 3.6.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_authorizer"></a> [authorizer](#module\_authorizer) | terraform-aws-modules/lambda/aws | 8.0.1 |
| <a name="module_authorizer_resource_role"></a> [authorizer\_resource\_role](#module\_authorizer\_resource\_role) | ./modules/apigw_resource_role | n/a |
| <a name="module_deploy_lambda"></a> [deploy\_lambda](#module\_deploy\_lambda) | terraform-aws-modules/lambda/aws | 8.0.1 |
| <a name="module_hello_api"></a> [hello\_api](#module\_hello\_api) | terraform-aws-modules/lambda/aws | 8.0.1 |
| <a name="module_hello_api_deployment"></a> [hello\_api\_deployment](#module\_hello\_api\_deployment) | ./modules/lambda_alias_deployment | n/a |
| <a name="module_hello_resource_role"></a> [hello\_resource\_role](#module\_hello\_resource\_role) | ./modules/apigw_resource_role | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_api_gateway_account.apigw_account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_account) | resource |
| [aws_api_gateway_deployment.prd](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_deployment) | resource |
| [aws_api_gateway_method_settings.all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_settings) | resource |
| [aws_api_gateway_rest_api.apigw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api) | resource |
| [aws_api_gateway_stage.prd](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_stage) | resource |
| [aws_cloudwatch_event_rule.api_push_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.api_push_version_lambda_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.api_push_version_log_group_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.api_push_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecr_repository.authorizer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository.hello_api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_iam_role.apigw_account_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_lambda_alias.hello_api_prd](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_alias) | resource |
| [aws_lambda_permission.eventbridge_push](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [docker_image.authorizer](https://registry.terraform.io/providers/kreuzwerker/docker/3.6.2/docs/resources/image) | resource |
| [docker_image.hello_api](https://registry.terraform.io/providers/kreuzwerker/docker/3.6.2/docs/resources/image) | resource |
| [docker_registry_image.authorizer](https://registry.terraform.io/providers/kreuzwerker/docker/3.6.2/docs/resources/registry_image) | resource |
| [docker_registry_image.hello_api](https://registry.terraform.io/providers/kreuzwerker/docker/3.6.2/docs/resources/registry_image) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ecr_authorization_token.token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecr_authorization_token) | data source |
| [aws_iam_policy_document.apigw_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.apigw_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.deploy_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_authorizer_tag"></a> [authorizer\_tag](#input\_authorizer\_tag) | Authorizer version tag to release. This value comes from Github worflow. | `string` | `""` | no |
| <a name="input_git_sha"></a> [git\_sha](#input\_git\_sha) | SHA value of the commit. This value comes from Github worflow. | `string` | n/a | yes |
| <a name="input_hello_api_tag"></a> [hello\_api\_tag](#input\_hello\_api\_tag) | Hello API version tag to release. This value comes from Github worflow. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_authorizer_docker_full_names"></a> [authorizer\_docker\_full\_names](#output\_authorizer\_docker\_full\_names) | n/a |
| <a name="output_hello_docker_full_names"></a> [hello\_docker\_full\_names](#output\_hello\_docker\_full\_names) | n/a |
| <a name="output_valid_api_tags"></a> [valid\_api\_tags](#output\_valid\_api\_tags) | n/a |
| <a name="output_valid_authorizer_tags"></a> [valid\_authorizer\_tags](#output\_valid\_authorizer\_tags) | n/a |
<!-- END_TF_DOCS -->
