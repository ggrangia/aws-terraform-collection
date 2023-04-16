module "lambda_tgw_rt_propagation" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "tgw_rt_propagation"
  description   = "Associate the attachmen with the TGW Rt specified in the tags and propagate it accordingly"
  handler       = "index.lambda_handler"
  runtime       = "python3.9"

  source_path = "./lambdas_code/tgw_rt_propagation/index.py"

  layers = [
    "arn:aws:lambda:eu-west-1:017000801446:layer:AWSLambdaPowertoolsPythonV2:26",
  ]

  tags = {
    Name = "tgw_rt_propagation"
  }
}


resource "aws_lambda_permission" "sns_network_manager" {
  statement_id_prefix = "sns_network_manager"
  action              = "lambda:InvokeFunction"
  function_name       = module.lambda_tgw_rt_propagation.lambda_function_name
  principal           = "sns.amazonaws.com"
  source_arn          = aws_sns_topic.network_manager.arn
}