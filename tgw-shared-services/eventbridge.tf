resource "aws_cloudwatch_event_rule" "vpc_attachment_created" {
  provider    = aws.netmanager
  name        = "vpc_attachment_created"
  description = "Capture each Network Manager event"

  event_pattern = jsonencode({
    "source" : ["aws.networkmanager"],
    "detail-type" : ["Network Manager Topology Change"],
    "detail" : {
      "changeType" : [{ "equals-ignore-case" : "vpc-attachment-created" }],
      "region" : [{ "equals-ignore-case" : "eu-west-1" }]
    }
  })

  depends_on = [
    aws_networkmanager_transit_gateway_registration.tgwthis
  ]
}

resource "aws_cloudwatch_log_group" "vpc_attachment_created" {
  provider = aws.netmanager

  name              = "/aws/events/vpcAttachmentCreatedLogGroup"
  retention_in_days = 7

}

resource "aws_cloudwatch_event_target" "vpc_attachment_created_log_group" {
  provider = aws.netmanager

  rule = aws_cloudwatch_event_rule.vpc_attachment_created.name
  arn  = aws_cloudwatch_log_group.vpc_attachment_created.arn
}

resource "aws_cloudwatch_event_target" "vpc_attachment_created_sns" {
  provider = aws.netmanager

  rule = aws_cloudwatch_event_rule.vpc_attachment_created.name
  arn  = aws_sns_topic.network_manager.arn
}
