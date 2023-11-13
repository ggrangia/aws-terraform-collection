
data "aws_iam_policy_document" "codebuild_trust_policy" {
  statement {
    sid     = "Trust"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "codebuild_policy" {
  statement {
    sid = "S3"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation",
      "s3:*" // FIXME: too open
    ]
    resources = [
      //aws_s3_bucket.testdata_bucket.arn,
      //"${aws_s3_bucket.testdata_bucket.arn}/*",
      aws_s3_bucket.codepipeline.arn,
      "${aws_s3_bucket.codepipeline.arn}/*",
      //"arn:aws:s3:::codepipeline-${data.aws_region.current.name}-*"
    ]
  }
  statement {
    sid       = "codepipeline"
    actions   = ["codepipeline:*"]
    resources = [aws_codepipeline.codepipeline.arn]
  }
  statement {
    sid       = "codebuild"
    actions   = ["codebuild:*"]
    resources = ["*"]
  }
  statement {
    sid       = "ecr"
    actions   = ["ecr:*"]
    resources = ["*"]
  }
  statement {
    sid = "logs"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
  statement {
    sid = "vpc"
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcs",
      "ec2:CreateNetworkInterfacePermission"
    ]
    resources = ["*"]
  }

}

resource "aws_iam_role" "codebuild" {
  name               = "codebuild"
  assume_role_policy = data.aws_iam_policy_document.codebuild_trust_policy.json
}

resource "aws_iam_policy" "codebuild_policy" {
  name        = "codebuild-policy"
  path        = "/"
  description = "codebuild_policy"
  policy      = data.aws_iam_policy_document.codebuild_policy.json
}

resource "aws_iam_role_policy_attachment" "codebuild_policy_attachment" {
  policy_arn = aws_iam_policy.codebuild_policy.arn
  role       = aws_iam_role.codebuild.id
}
