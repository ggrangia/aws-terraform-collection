module "lambda_tgw_accept_attachment" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "tgw_accept_attachment"
  description   = "Accept incoming "
  handler       = "index.lambda_handler"
  runtime       = "python3.9"

  source_path = "./lambdas_code/tgw_association/index.py"

  layers = [
    "arn:aws:lambda:eu-west-1:017000801446:layer:AWSLambdaPowertoolsPythonV2:26",
  ]

  attach_policy_json = true
  policy_json        = data.aws_iam_policy_document.netman_sqs.json

  tags = {
    Name = "tgw_accept_attachment"
  }
}

data "aws_iam_policy_document" "netman_sqs" {
  statement {
    sid = "ReadFromSqs"

    actions = [
      "sqs:DeleteMessage",
      "sqs:ChangeMessageVisibility",
      "sqs:ReceiveMessage",
      "sqs:GetQueueAttributes"
    ]

    resources = [
      aws_sqs_queue.network_manager_queue.arn,
      #"arn:aws:sqs:us-east-2:${data.aws_caller_identity.netmanager.account_id}:network_manager_queue"
    ]
  }

}

resource "aws_lambda_permission" "sns_network_manager" {
  statement_id_prefix = "sns_network_manager"
  action              = "lambda:InvokeFunction"
  function_name       = module.lambda_tgw_accept_attachment.lambda_function_name
  principal           = "sns.amazonaws.com"
  source_arn          = aws_sns_topic.network_manager.arn
}