resource "aws_codecommit_repository" "repo" {
  repository_name = "ecs-test-repo"
  description     = "ecs-test-repo"
  default_branch  = "main"
}

resource "aws_cloudwatch_event_rule" "commit" {
  name        = "${aws_codecommit_repository.repo.repository_id}-capture-commit-event"
  description = "Capture repo commit"

  event_pattern = jsonencode({
    "source" : ["aws.codecommit"],
    "detail-type" : ["CodeCommit Repository State Change"],
    "resources" : ["${aws_codecommit_repository.repo.arn}"]
    "detail" : {
      "referenceType" : ["branch"],
      "referenceName" : ["main"]
    }
  })
}

resource "aws_cloudwatch_event_target" "event_target" {
  target_id = "1"
  rule      = aws_cloudwatch_event_rule.commit.name
  arn       = aws_codepipeline.codepipeline.arn
  role_arn  = aws_iam_role.eventbridge_codecommit.arn
}

