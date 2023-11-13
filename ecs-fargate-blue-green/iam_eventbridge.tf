
resource "aws_iam_role" "eventbridge_codecommit" {
  name               = "cloudwatch_service_role"
  path               = "/service-role/"
  assume_role_policy = data.aws_iam_policy_document.eventbridge_codecommit_trust_policy.json
}

data "aws_iam_policy_document" "eventbridge_codecommit_trust_policy" {
  statement {
    sid     = "AssumePolicy"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "eventbridge_codecommit" {
  statement {
    actions   = ["codepipeline:Start*"]
    resources = [aws_codepipeline.codepipeline.arn]
  }
}

resource "aws_iam_policy" "eventbridge_codecommit" {
  name   = "eventbridge_codecommit_codepipeline_policy"
  policy = data.aws_iam_policy_document.eventbridge_codecommit.json
}

resource "aws_iam_role_policy_attachment" "eventbridge_codecommit" {
  role       = aws_iam_role.eventbridge_codecommit.name
  policy_arn = aws_iam_policy.eventbridge_codecommit.arn
}
