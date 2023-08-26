/*
EventBridge ignores the fields in the event that aren't included in the event pattern.
The effect is that there is a "*": "*" wildcard for fields that don't appear in the event pattern.
https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-event-patterns-content-based-filtering.html
*/

/*
To keep things simple, react only to push on main branch.
In this example, the event reacts also the all the brach starting with "feature/"
*/
resource "aws_cloudwatch_event_rule" "codecommit_events" {
  name        = "codecommit_events"
  description = "Capture each Codecommit push or merge PR on selected repositories"

  event_pattern = jsonencode({
    "source" : [
      "aws.codecommit"
    ],
    "detail-type" : [
      "CodeCommit Repository State Change"
    ],
    "resources" : [
      "${aws_codecommit_repository.myrepo1.arn}",
      "${aws_codecommit_repository.myrepo2.arn}"
    ],
    "detail" : {
      "event" : [
        "referenceUpdated"
      ],
      "referenceType" : [
        "branch"
      ],
      "referenceName" : [
        "main",
        { "prefix" : "feature/" },
      ]
    }
  })
}

resource "aws_cloudwatch_event_target" "cwlogs" {

  rule      = aws_cloudwatch_event_rule.codecommit_events.name
  target_id = "SendtoCloudwatchLogs"
  arn       = aws_cloudwatch_log_group.codecommit_events.arn
}

resource "aws_cloudwatch_log_group" "codecommit_events" {

  name = "/aws/events/codecommit_events"
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.codecommit_events.name
  target_id = "SendToLambda"
  arn       = module.codecommit_event_lambda.lambda_function_arn
}
