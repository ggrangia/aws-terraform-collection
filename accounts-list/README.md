This project deploys an automation that reacts when new accounts are created or removed. The events are captured and triggers a lambda functions that creates a list of all the accounts and uploads it to an S3 bucket.

## Description

The main goal of this project is to avoid 429 errors (too many requests) from AWS Organizations API. This may happen when several projects are deploying at the same time and the automation builds the provider by fertching the accounts (e.g. with atlantis custom workflows).

The resources are deployed in two separate accounts:

- Org root account (where accounts events are triggered)
- Target account (where the lambda and the final artifact will reside)

![Arch diagram](/accounts-list/img/accounts-list.jpg)

The event is captured in the Org account and forwarded to the event bus in the Target account. The same rule is present here, but this time the target is the lambda function.

The lambda function performs gets the list of all the accounts and for each of those it gets all the tags. It then creates a json and uploads it to an S3 bucket.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |
| <a name="provider_aws.org"></a> [aws.org](#provider\_aws.org) | ~> 6.0 |
| <a name="provider_aws.target"></a> [aws.target](#provider\_aws.target) | ~> 6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_lambda_function"></a> [lambda\_function](#module\_lambda\_function) | terraform-aws-modules/lambda/aws | ~>8.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_bus.aws_organizations_changes_capture_event_bus](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_bus) | resource |
| [aws_cloudwatch_event_permission.aws_organizations_changes_capture_event_bus_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_permission) | resource |
| [aws_cloudwatch_event_rule.aws_organizations_changes_capture_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_rule.aws_organizations_changes_capture_rule_management](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.aws_cloudwatch_event_target_event_bus](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.aws_cloudwatch_event_target_sqs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_iam_role.eventbridge_invoke_event_bus_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.eventbridge_invoke_event_bus_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_s3_bucket.accounts_list_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [archive_file.lambda_zip](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.org](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.eventbridge_invoke_event_bus_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_python_version"></a> [python\_version](#input\_python\_version) | n/a | `string` | `"python3.13"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
