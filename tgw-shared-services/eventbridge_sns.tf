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
  endpoint  = module.lambda_tgw_rt_propagation.lambda_function_arn
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

resource "aws_sns_topic_policy" "eventbridge" {
  provider = aws.netmanager
  arn      = aws_sns_topic.network_manager.arn

  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

# Allow events to Publish to SNS
data "aws_iam_policy_document" "sns_topic_policy" {
  provider  = aws.netmanager
  policy_id = "__default_policy_ID"

  statement {
    sid    = "__default_statement_ID"
    effect = "Allow"

    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"
      values   = [data.aws_caller_identity.current.account_id]
    }

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [aws_sns_topic.network_manager.arn]
  }

  statement {
    sid     = "AWSEvents_capture-autoscaling-events_SendToSNS"
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [aws_sns_topic.network_manager.arn]
  }
}
