resource "aws_sns_topic" "network_manager" {
  provider = aws.netmanager

  name                                = "network_manager"
  lambda_failure_feedback_role_arn    = "arn:aws:iam::605665581171:role/SNSFailureFeedback"
  lambda_success_feedback_role_arn    = "arn:aws:iam::605665581171:role/SNSSuccessFeedback"
  lambda_success_feedback_sample_rate = 100
}

resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  provider = aws.netmanager

  topic_arn = aws_sns_topic.network_manager.arn
  protocol  = "lambda"
  endpoint  = module.lambda_tgw_accept_attachment.lambda_function_arn
}
