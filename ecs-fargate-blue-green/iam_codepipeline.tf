data "aws_iam_policy_document" "codepipeline_trust_policy" {
  statement {
    sid     = "Trust"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codepipeline" {
  name               = "codepipeline_role"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_trust_policy.json
}

data "aws_iam_policy_document" "codepipeline_policy" {
  statement {
    sid       = "PassRole"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = ["*"]
    condition {
      test = "StringEqualsIfExists"
      values = [
        "cloudformation.amazonaws.com",
        "elasticbeanstalk.amazonaws.com",
        "ec2.amazonaws.com",
        "ecs-tasks.amazonaws.com"
      ]
      variable = "iam:PassedToService"
    }
  }
  statement {
    sid    = "Codecommit"
    effect = "Allow"
    actions = [
      "codecommit:CancelUploadArchive",
      "codecommit:GetBranch",
      "codecommit:GetCommit",
      "codecommit:GetUploadArchiveStatus",
      "codecommit:UploadArchive"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "misc"
    effect = "Allow"
    actions = [
      "cloudwatch:*",
      "s3:*",
      "sns:*",
      "sqs:*",
      "ecs:*"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "lambda"
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
      "lambda:ListFunctions"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "codebuild"
    effect = "Allow"
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "codedeploy"
    effect = "Allow"
    actions = [
      "*", // FIXME: too open
      "codedeploy:CreateDeployment",
      "codedeploy:GetApplication",
      "codedeploy:GetApplicationRevision",
      "codedeploy:GetDeployment",
      "codedeploy:GetDeploymentConfig",
      "codedeploy:RegisterApplicationRevision"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "codepipeline_policy"
  role   = aws_iam_role.codepipeline.id
  policy = data.aws_iam_policy_document.codepipeline_policy.json
}
