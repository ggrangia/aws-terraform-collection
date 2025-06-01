resource "aws_iam_policy" "deploy_lambda" {
  name        = "DeployPolicy"
  description = "Permissions to deploy lambda and trigger codedeploy"
  policy      = data.aws_iam_policy_document.deploy_lambda.json
}

resource "aws_iam_role" "deploy_lambda_sfn" {
  name               = "DeployLambdaStepFunction"
  assume_role_policy = data.aws_iam_policy_document.deploy_lambda_sfn_assume.json
  description        = "This role allows the Step Function to deploy the new Lambdas"
}

data "aws_iam_policy_document" "deploy_lambda_sfn_assume" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


resource "aws_sfn_state_machine" "deploy_lambda_sfn" {
  name     = "DeployLambdaStepFunction"
  role_arn = aws_iam_role.deploy_lambda_sfn.arn

  definition = file("${path.module}/deploy_lambda_sfn.json")

  type = "STANDARD"
}
