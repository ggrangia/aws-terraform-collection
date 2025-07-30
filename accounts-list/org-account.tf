resource "aws_cloudwatch_event_rule" "aws_organizations_changes_capture_rule_management" {
  depends_on = [aws_cloudwatch_event_permission.aws_organizations_changes_capture_event_bus_policy]

  provider = aws.org

  name          = "aws-organizations-changes-capture-rule"
  description   = "EventBridge rule used to capture and forward AWS Organizations changes to target account event bus"
  event_pattern = jsonencode(local.org_event_pattern)
}

data "aws_iam_policy_document" "eventbridge_invoke_event_bus_role_policy" {
  statement {
    effect    = "Allow"
    actions   = ["events:PutEvents"]
    resources = [aws_cloudwatch_event_bus.aws_organizations_changes_capture_event_bus.arn]
  }
}

resource "aws_iam_role_policy" "eventbridge_invoke_event_bus_role_policy" {
  depends_on = [aws_cloudwatch_event_permission.aws_organizations_changes_capture_event_bus_policy]

  provider = aws.org

  name   = "aws-organizations-changes-capture-event-bus-role-policy"
  role   = aws_iam_role.eventbridge_invoke_event_bus_role.name
  policy = data.aws_iam_policy_document.eventbridge_invoke_event_bus_role_policy.json
}

resource "aws_iam_role" "eventbridge_invoke_event_bus_role" {
  depends_on = [aws_cloudwatch_event_permission.aws_organizations_changes_capture_event_bus_policy]

  provider = aws.org

  name = "aws-organizations-changes-capture-event-bus-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_cloudwatch_event_target" "aws_cloudwatch_event_target_event_bus" {
  depends_on = [aws_cloudwatch_event_permission.aws_organizations_changes_capture_event_bus_policy]

  provider = aws.org

  arn      = aws_cloudwatch_event_bus.aws_organizations_changes_capture_event_bus.arn
  rule     = aws_cloudwatch_event_rule.aws_organizations_changes_capture_rule_management.name
  role_arn = aws_iam_role.eventbridge_invoke_event_bus_role.arn
}
