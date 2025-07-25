resource "aws_iam_role" "apigw_resource_role" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "example" {
  name = "${var.role_name}_invoke_private_policy"
  role = aws_iam_role.apigw_resource_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["lambda:InvokeFunction"]
        Resource = var.lambda_arns
        Effect   = "Allow"
      }
    ]
  })
}
