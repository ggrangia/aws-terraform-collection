data "aws_iam_policy_document" "deploy_lambda" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "codedeploy:GetDeployment",
      "codedeploy:GetDeploymentConfig",
      "codedeploy:CreateDeployment",
      "codedeploy:RegisterApplicationRevision"
    ]
  }

  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "lambda:GetFunction",
      "lambda:PublishVersion",
      "lambda:CreateAlias",
      "lambda:UpdateAlias",
      "lambda:GetAlias"
    ]
  }
}


module "deploy_lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "8.0.1"

  function_name = "deploy_lambda"
  description   = ""
  handler       = "index.lambda_handler"
  runtime       = "python3.12"

  source_path = "./src/deploy_lambda/index.py"

  layers  = ["arn:aws:lambda:${data.aws_region.current.name}:017000801446:layer:AWSLambdaPowertoolsPythonV2:65"]
  timeout = 60

  attach_policy_json = true
  policy_json        = data.aws_iam_policy_document.deploy_lambda.json

  environment_variables = {
    POWERTOOLS_SERVICE_NAME = "DEPLOY_LAMBDA"
  }
}

resource "aws_lambda_permission" "eventbridge_push" {
  statement_id_prefix = "eventbridge_push"
  action              = "lambda:InvokeFunction"
  function_name       = module.deploy_lambda.lambda_function_name
  principal           = "events.amazonaws.com"
  source_arn          = aws_cloudwatch_event_rule.api_push_version.arn
}
