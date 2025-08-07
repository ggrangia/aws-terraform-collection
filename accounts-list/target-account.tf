data "aws_caller_identity" "org" {
  provider = aws.org
}

data "aws_region" "target" {
  provider = aws.target
}

resource "aws_cloudwatch_event_bus" "aws_organizations_changes_capture_event_bus" {
  provider = aws.target

  name = "organizations-changes-capture-event-bus"
}

resource "aws_cloudwatch_event_permission" "aws_organizations_changes_capture_event_bus_policy" {
  provider = aws.target

  principal      = data.aws_caller_identity.org.account_id
  statement_id   = "allow-management-account-to-put-events"
  event_bus_name = aws_cloudwatch_event_bus.aws_organizations_changes_capture_event_bus.name
  action         = "events:PutEvents"
}

resource "aws_cloudwatch_event_rule" "aws_organizations_changes_capture_rule" {
  provider = aws.target

  name           = "aws-organizations-changes-capture-rule"
  description    = "EventBridge rule used to trigger Account Documentor pipeline upon AWS Organizations changes"
  event_bus_name = aws_cloudwatch_event_bus.aws_organizations_changes_capture_event_bus.name
  event_pattern  = jsonencode(local.org_event_pattern)
}

resource "aws_cloudwatch_event_target" "aws_cloudwatch_event_target_sqs" {
  provider = aws.target

  arn            = module.lambda_function.lambda_function_arn
  rule           = aws_cloudwatch_event_rule.aws_organizations_changes_capture_rule.name
  event_bus_name = aws_cloudwatch_event_bus.aws_organizations_changes_capture_event_bus.arn
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/src/accounts-list/index.py"
  output_path = "${path.module}/src/accounts-list.zip"
}

module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~>8.0"

  providers = {
    aws = aws.target
  }

  architectures = ["arm64"]

  function_name = "accounts-list"
  description   = "This function creates a list with all the accounts and it uploads it to S3."

  handler = "index.lambda_handler"
  runtime = var.python_version
  publish = true

  create_package         = false
  local_existing_package = data.archive_file.lambda_zip.output_path

  memory_size = 256
  timeout     = 60

  attach_policy_statements = true
  policy_statements = {
    AllowS3PutObject = {
      effect    = "Allow",
      actions   = ["s3:PutObject"],
      resources = ["arn:aws:s3:::${aws_s3_bucket.accounts_list_bucket}/*"]
    }
    AllowOrgRead = {
      effect = "Allow",
      actions = [
        "organizations:ListAccounts",
        "organizations:DescribeAccount",
        "organizations:ListTagsForResource"
      ],
      resources = ["*"]
    }
  }

  layers = [
    "arn:aws:lambda:${data.aws_region.target.region}:017000801446:layer:AWSLambdaPowertoolsPythonV3-${replace(var.python_version, ".", "")}-arm64:18",
  ]

  allowed_triggers = {
    alloworgcatchevent = {
      principal  = "events.amazonaws.com"
      source_arn = aws_cloudwatch_event_rule.aws_organizations_changes_capture_rule.arn
    }
  }

  environment_variables = {
    POWERTOOLS_SERVICE_NAME = "accounts-list"
    POWERTOOLS_LOG_LEVEL    = "INFO"
  }
}


resource "aws_s3_bucket" "accounts_list_bucket" {
  provider = aws.target

  bucket = "accounts_list_bucket"
}
