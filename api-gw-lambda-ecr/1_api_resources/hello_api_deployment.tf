/*
Resources:
https://docs.aws.amazon.com/codedeploy/latest/userguide/reference-appspec-file-structure-resources.html

*/

locals {
  appspec = jsonencode({
    version = "0.0"
    Resources = [
      {
        FunctionDeployment = {
          Name           = module.hello_api.lambda_function_name
          Alias          = ""
          CurrentVersion = "" # FIXME: int or str?
          TargetVersion  = ""
        }
      }
    ]
  })
}

resource "aws_codedeploy_app" "hello_api" {
  compute_platform = "Lambda"
  name             = "hello_api"
}

resource "aws_codedeploy_deployment_group" "hello_api" {
  app_name               = aws_codedeploy_app.hello_api.name
  deployment_group_name  = "hello_api"
  deployment_config_name = "CodeDeployDefault.LambdaAllAtOnce"
  service_role_arn       = aws_iam_role.hello_api_codedeploy_role.arn

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_STOP_ON_ALARM", "DEPLOYMENT_FAILURE"]
  }

}

data "aws_iam_policy_document" "hello_api_deployment_assume_role" {

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "hello_api_codedeploy_role" {
  name               = "hello_api_codedeploy_role"
  assume_role_policy = data.aws_iam_policy_document.hello_api_deployment_assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.hello_api_codedeploy_role.name
  policy_arn = data.aws_iam_policy.aws_codedeploy_for_lambda.arn
}
