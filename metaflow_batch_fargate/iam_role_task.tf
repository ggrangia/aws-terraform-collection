// https://docs.aws.amazon.com/batch/latest/userguide/execution-IAM-role.html
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "tf_test_batch_exec_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ecs_assume_compute_env_role" {
  statement {
    actions = ["sts:AssumeRole"]

    resources = [aws_iam_role.aws_batch_service_role.arn]
  }
}

resource "aws_iam_policy" "ecs_assume_compute_env_role" {
  name   = "ecs_assume_compute_env_role"
  policy = data.aws_iam_policy_document.ecs_assume_compute_env_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_assume_compute_env_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_assume_compute_env_role.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
