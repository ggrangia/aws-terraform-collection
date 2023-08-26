data "aws_iam_policy_document" "lambda_event" {

  statement {
    effect    = "Allow"
    actions   = ["logs:*"]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["codebuild:StartBuild"]
    resources = [aws_codebuild_project.create_dynamic_pipeline.arn] // FIXME:
  }
}

module "codecommit_event_lambda" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "codecommit_event_lambda"
  description   = "Receive event from eventbridge and starts a codebuild overriding source"
  handler       = "index.lambda_handler"
  runtime       = "python3.10"
  timeout       = 90

  source_path = "./lambdas_code/codecommit_event_lambda/index.py"

  layers = [
    "arn:aws:lambda:eu-west-1:017000801446:layer:AWSLambdaPowertoolsPythonV2:41",
  ]

  environment_variables = {
    POWERTOOLS_SERVICE_NAME = "codecommit_event_lambda"
    LOG_LEVEL               = "INFO"
    CODEBUILD_PROJECT       = "${aws_codebuild_project.create_dynamic_pipeline.name}"
  }

  attach_policy_json = true
  policy_json        = data.aws_iam_policy_document.lambda_event.json
  tags = {
    Name = "codecommit_event_lambda"
  }
}

resource "aws_lambda_permission" "sns_network_manager" {
  statement_id_prefix = "eventbridge_permission"
  action              = "lambda:InvokeFunction"
  function_name       = module.codecommit_event_lambda.lambda_function_name
  principal           = "events.amazonaws.com"
  source_arn          = aws_cloudwatch_event_rule.codecommit_events.arn
}
