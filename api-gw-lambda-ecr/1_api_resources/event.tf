resource "aws_cloudwatch_event_rule" "api_push_version" {
  name        = "api_push_version"
  description = "Capture each AWS Console Sign In"

  event_pattern = jsonencode({
    source = ["aws.ecr"]
    detail-type = [
      "ECR Image Action"
    ]
    detail = {
      action-type     = ["PUSH"]
      result          = ["SUCCESS"]
      repository-name = [aws_ecr_repository.hello_api.name]
      image-tag       = [{ prefix = "v" }]
    }
  })
}

resource "aws_cloudwatch_log_group" "api_push_version" {
  name              = "/aws/events/apiPushVersionLogGroup"
  retention_in_days = 7
}

resource "aws_cloudwatch_event_target" "api_push_version_log_group_target" {
  rule = aws_cloudwatch_event_rule.api_push_version.name
  arn  = aws_cloudwatch_log_group.api_push_version.arn
}

resource "aws_cloudwatch_event_target" "api_push_version_lambda_target" {
  rule = aws_cloudwatch_event_rule.api_push_version.name
  arn  = module.deploy_lambda.lambda_function_arn
}
