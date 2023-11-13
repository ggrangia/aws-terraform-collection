resource "aws_s3_bucket" "codepipeline" {
  bucket = "ecs-test-bucket-pipeline-1233"
}

resource "aws_s3_bucket_ownership_controls" "codepipeline" {
  bucket = aws_s3_bucket.codepipeline.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "codepipeline" {
  depends_on = [aws_s3_bucket_ownership_controls.codepipeline]

  bucket = aws_s3_bucket.codepipeline.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "codepipeline" {
  bucket = aws_s3_bucket.codepipeline.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_codepipeline" "codepipeline" {
  name     = "ecs-test-pipeline"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName       = aws_codecommit_repository.repo.repository_name
        BranchName           = "main"
        PollForSourceChanges = false
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.codebuild.name
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      category        = "Deploy"
      name            = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      version         = "1"
      input_artifacts = ["build_output"]

      // https://docs.aws.amazon.com/AmazonECS/latest/developerguide/create-blue-green.html
      // https://docs.aws.amazon.com/codepipeline/latest/userguide/action-reference-ECSbluegreen.html
      configuration = {
        ApplicationName                = aws_codedeploy_app.client.name
        DeploymentGroupName            = var.codedeploy_app_name
        AppSpecTemplateArtifact        = "build_output"
        AppSpecTemplatePath            = "appspec.yml"
        TaskDefinitionTemplateArtifact = "build_output"
        TaskDefinitionTemplatePath     = "taskdef.json"
      }
    }
  }

}

