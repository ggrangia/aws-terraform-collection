
resource "aws_iam_role" "client_task_role" {
  name = "client_task_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

data "aws_iam_policy_document" "client_task_policy_doc" {
  statement {
    sid       = "1"
    actions   = ["*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "client_task_policy" {
  name   = "client_task_policy"
  policy = data.aws_iam_policy_document.client_task_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "client_task_policy_attach" {
  role       = aws_iam_role.client_task_role.name
  policy_arn = aws_iam_policy.client_task_policy.arn
}

resource "aws_cloudwatch_log_group" "client_lg" {
  name = "/aws/ecs/client_lg"
}


resource "aws_ecs_task_definition" "client" {
  family                   = "client_task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.client_task_role.arn
  container_definitions    = file("container_definitions.json")

}
