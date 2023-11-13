resource "aws_s3_bucket" "codepipeline_container" {
  bucket = "ecs-test-bucket-codepipeline-container-1233"
}

// https://github.com/hashicorp/terraform-provider-aws/issues/28353
resource "aws_s3_bucket_ownership_controls" "codepipeline_container" {
  bucket = aws_s3_bucket.codepipeline_container.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "codepipeline_container" {
  depends_on = [aws_s3_bucket_ownership_controls.codepipeline_container]

  bucket = aws_s3_bucket.codepipeline_container.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "codepipeline_container" {
  bucket = aws_s3_bucket.codepipeline_container.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_codepipeline" "codepipeline_container" {
  name     = "container-pipeline"
  role_arn = aws_iam_role.codepipeline.arn // TODO: create new role

  artifact_store {
    location = aws_s3_bucket.codepipeline_container.bucket
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

}

