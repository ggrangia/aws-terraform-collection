resource "aws_iam_role" "codedeploy" {
  name = "codedeploy-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
      },
    ]
  })
}

data "aws_iam_policy_document" "codedeploy_policy_doc" {
  statement {
    sid    = "1"
    effect = "Allow"
    actions = [
      "*", // FIXME: reduce scope
      "ecs:DescribeServices",
      "ecs:CreateTaskSet",
      "ecs:UpdateServicePrimaryTaskSet",
      "ecs:DeleteTaskSet",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:DescribeRules",
      "elasticloadbalancing:ModifyRule",
      "lambda:InvokeFunction",
      "cloudwatch:DescribeAlarms",
      "sns:Publish",
      "s3:GetObject",
      "s3:GetObjectMetadata",
      "s3:GetObjectVersion"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "2"
    effect = "Allow"
    actions = [
      "iam:PassRole",
      "iam:GetRole"
    ]
    resources = [aws_iam_role.client_task_role.arn]
  }
  /*
  statement {
    sid    = "s3"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation"
    ]
    resources = [
      aws_s3_bucket.codepipeline.arn,
      "${aws_s3_bucket.codepipeline.arn}*",
    ]
  }
*/

  statement {
    sid       = "s3"
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "codedeploy_policy" {
  name   = "codedeploy_policy"
  policy = data.aws_iam_policy_document.codedeploy_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "codedeploy_policy_attach" {
  role       = aws_iam_role.codedeploy.name
  policy_arn = aws_iam_policy.codedeploy_policy.arn
}
