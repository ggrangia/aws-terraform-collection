resource "aws_iam_role" "metaflow_s3_role" {
  name = "metaflow_s3_role"

  description = "METAFLOW_ECS_S3_ACCESS_IAM_ROLE"

  assume_role_policy = data.aws_iam_policy_document.metaflow_s3_role_assume_role_policy.json
}

data "aws_iam_policy_document" "metaflow_s3_role_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "metaflow_s3_role_actions" {
  statement {
    actions = [
      "s3:ListBucket",
    ]

    effect = "Allow"

    resources = [aws_s3_bucket.dynamic_maps.arn]

  }

  statement {
    actions = [
      "s3:ListBucket",
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]

    effect = "Allow"

    resources = [
      "${aws_s3_bucket.dynamic_maps.arn}/*"
    ]
  }
}

resource "aws_iam_role_policy" "metaflow_s3_role_actions_policy" {
  name   = "metaflow_s3_role_actions"
  role   = aws_iam_role.metaflow_s3_role.name
  policy = data.aws_iam_policy_document.metaflow_s3_role_actions.json
}

resource "aws_iam_role_policy_attachment" "metaflow_ecs_task_execution_role_policy" {
  role       = aws_iam_role.metaflow_s3_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
