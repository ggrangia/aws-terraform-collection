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

![Arch diagram](/api-gw-lambda-ecr/img/aws_terraform_collection_apigw_ecr.jpg)
