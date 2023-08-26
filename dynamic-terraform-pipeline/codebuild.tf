data "aws_iam_policy_document" "create_dynamic_pipeline_trusted_entity" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "create_dynamic_pipeline" {
  statement {
    effect = "Allow"
    actions = [
      "codecommit:*",
      "codebuild:*",
      "codepipeline:*",
      "logs:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "create_dynamic_pipeline" {
  name = "create_dynamic_pipeline_role"

  assume_role_policy = data.aws_iam_policy_document.create_dynamic_pipeline_trusted_entity.json
}
resource "aws_iam_policy" "create_dynamic_pipeline_policy" {
  name        = "create_dynamic_pipeline_policy"
  description = "A policy used that gives permission to modify and create dymanic pipelines"
  policy      = data.aws_iam_policy_document.create_dynamic_pipeline.json
}
resource "aws_iam_role_policy_attachment" "create_dynamic_pipeline" {
  role       = aws_iam_role.create_dynamic_pipeline.name
  policy_arn = aws_iam_policy.create_dynamic_pipeline_policy.arn
}

resource "aws_codebuild_project" "create_dynamic_pipeline" {
  name          = "create_dynamic_pipeline"
  description   = ""
  build_timeout = "10"
  service_role  = aws_iam_role.create_dynamic_pipeline.arn

  source {
    type      = "NO_SOURCE"
    buildspec = file("./buildspec_dynamic.yml")
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }
}
