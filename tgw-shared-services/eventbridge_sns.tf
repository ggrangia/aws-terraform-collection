resource "aws_sns_topic" "network_manager" {
  provider = aws.netmanager

  name                                = "network_manager"
  lambda_failure_feedback_role_arn    = aws_iam_role.sns_logs.arn
  lambda_success_feedback_role_arn    = aws_iam_role.sns_logs.arn
  lambda_success_feedback_sample_rate = 0
}

resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  provider = aws.netmanager

  topic_arn = aws_sns_topic.network_manager.arn
  protocol  = "lambda"
  endpoint  = module.lambda_tgw_accept_attachment.lambda_function_arn
}

resource "aws_iam_role" "sns_logs" {
  provider = aws.netmanager
  name     = "sns_logs"

  assume_role_policy = data.aws_iam_policy_document.trusted_entity_sns_logs.json
  inline_policy {
    name   = "inline_sns"
    policy = data.aws_iam_policy_document.sns_logs.json
  }
}

data "aws_iam_policy_document" "sns_logs" {
  provider = aws.netmanager
  statement {
    actions = ["logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutMetricFilter",
    "logs:PutRetentionPolicy"]

    resources = ["*"]
  }
}


data "aws_iam_policy_document" "trusted_entity_sns_logs" {
  provider = aws.netmanager
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }
  }
}
