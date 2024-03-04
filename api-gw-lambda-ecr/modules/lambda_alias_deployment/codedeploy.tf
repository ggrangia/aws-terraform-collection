resource "aws_codedeploy_app" "this" {
  compute_platform = "Lambda"
  name             = var.lambda_name
}

resource "aws_codedeploy_deployment_group" "this" {
  app_name               = aws_codedeploy_app.this.name
  deployment_group_name  = var.lambda_name
  deployment_config_name = "CodeDeployDefault.LambdaAllAtOnce"
  service_role_arn       = aws_iam_role.this_codedeploy_role.arn

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_STOP_ON_ALARM", "DEPLOYMENT_FAILURE"]
  }

}

data "aws_iam_policy_document" "this_assume_role" {

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this_codedeploy_role" {
  name               = "${var.lambda_name}_codedeploy_role"
  assume_role_policy = data.aws_iam_policy_document.this_assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.this_codedeploy_role.name
  policy_arn = data.aws_iam_policy.aws_codedeploy_for_lambda.arn
}

# https://docs.aws.amazon.com/codedeploy/latest/userguide/reference-appspec-file.html#appspec-reference-lambda
#version: 0.0
# https://docs.aws.amazon.com/codedeploy/latest/userguide/reference-appspec-file-structure-resources.html#reference-appspec-file-structure-resources-lambda
#Resources:
#  - myLambdaFunction:
#      Type: AWS::Lambda::Function
#      Properties:
#        Name: "hello_api"
#        Alias: "prd"
#        CurrentVersion: "33"
#        TargetVersion: "34"
