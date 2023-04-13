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

resource "aws_cloudwatch_event_target" "netman_sns" {
  provider = aws.netmanager

  rule = aws_cloudwatch_event_rule.networkmanager.name
  arn  = aws_sns_topic.network_manager.arn
}
