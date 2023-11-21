data "aws_iam_policy_document" "after_allow_test_hook_policy_doc" {
  statement {
    sid = "codedeploy"

    actions = ["codedeploy:PutLifecycleEventHookExecutionStatus"]

    resources = ["*"]
  }
}

module "after_allow_test_hook" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "after_allow_test_hook"
  description   = "Run tests on the green group after the test listener is up"
  handler       = "index.lambda_handler"
  runtime       = "python3.11"

  source_path = "./lambdas/after_allow_test_hook/index.py"

  layers = ["arn:aws:lambda:us-east-1:017000801446:layer:AWSLambdaPowertoolsPythonV2:46"]

  attach_policy_json = true
  policy_json        = data.aws_iam_policy_document.after_allow_test_hook_policy_doc.json

  environment_variables = {
    "POWERTOOLS_SERVICE_NAME" = "after_allow_test_hook"
    "LOG_LEVEL"               = "INFO"
    "ALB_DNS_NAME"            = aws_lb.my_alb.dns_name
    "TEST_LISTENER_PORT"      = aws_lb_listener.client2_listener.port
  }
}
