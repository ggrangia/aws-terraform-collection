resource "aws_cloudwatch_event_rule" "networkmanager" {
  provider    = aws.netmanager
  name        = "capture-networkmanager"
  description = "Capture each Network Manager event"

  event_pattern = jsonencode({
    "source" : ["aws.networkmanager"]
  })

  depends_on = [
    aws_networkmanager_transit_gateway_registration.tgwthis
  ]
}

resource "aws_cloudwatch_log_group" "customNetManagerLogGroup" {
  provider = aws.netmanager

  name              = "/aws/events/customNetManagerLogGroup"
  retention_in_days = 7

}

resource "aws_cloudwatch_event_target" "netman_log_group" {
  provider = aws.netmanager

  rule = aws_cloudwatch_event_rule.networkmanager.name
  arn  = aws_cloudwatch_log_group.customNetManagerLogGroup.arn
}

resource "aws_sqs_queue" "network_manager_queue" {
  provider = aws.netmanager

  name                       = "network_manager_queue"
  visibility_timeout_seconds = 30
  message_retention_seconds  = 86400 # 1 day
  receive_wait_time_seconds  = 0
}


resource "aws_cloudwatch_event_target" "netman_sqs" {
  provider = aws.netmanager

  rule = aws_cloudwatch_event_rule.networkmanager.name
  arn  = aws_sqs_queue.network_manager_queue.arn
}

data "aws_iam_policy_document" "cross_sqs" {
  provider = aws.netmanager

  statement {
    sid = "AllowNetworkEvents"

    actions = ["sqs:SendMessage"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudwatch_event_rule.networkmanager.arn]
    }
  }

  statement {
    sid = "AllowLambda"

    actions = ["sqs:*"]
    principals {
      type        = "AWS"
      identifiers = [module.lambda_tgw_accept_attachment.lambda_role_arn]
    }
    resources = [aws_sqs_queue.network_manager_queue.arn]
  }
}

resource "aws_sqs_queue_policy" "cross_sqs" {
  provider = aws.netmanager

  queue_url = aws_sqs_queue.network_manager_queue.id
  policy    = data.aws_iam_policy_document.cross_sqs.json
}

resource "aws_cloudwatch_event_target" "netman_sns" {
  provider = aws.netmanager

  rule = aws_cloudwatch_event_rule.networkmanager.name
  arn  = aws_sns_topic.network_manager.arn
}
