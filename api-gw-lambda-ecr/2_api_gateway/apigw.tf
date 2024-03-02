resource "aws_api_gateway_rest_api" "example" {
  name = "myapiv1"

  body = templatefile("${path.root}/openapi.yml.tpl", {
    endpoint_api1_lambda = module.alias_prd.lambda_alias_invoke_arn
    endpoint_api1_role   = module.hello_resource_role.role_arn

    authorizer_lambda      = module.authorizer.lambda_function_invoke_arn
    authorizer_credentials = module.authorizer_resource_role.role_arn
  })

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}


resource "aws_api_gateway_deployment" "prd" {
  rest_api_id = aws_api_gateway_rest_api.example.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.example.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "prd" {
  deployment_id = aws_api_gateway_deployment.prd.id
  rest_api_id   = aws_api_gateway_rest_api.example.id
  stage_name    = "prd"
}


module "hello_resource_role" {
  source = "./modules/apigw_resource_role"

  role_name   = "hello_api_resource_role"
  lambda_arns = ["${module.hello_api.lambda_function_arn}*"] # Use the lambda arn in the resource role, not the invoke arn
}


module "authorizer_resource_role" {
  source = "./modules/apigw_resource_role"

  role_name   = "authorizer_resource_role"
  lambda_arns = ["${module.authorizer.lambda_function_arn}*"]
}

resource "aws_api_gateway_method_settings" "all" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  stage_name  = aws_api_gateway_stage.prd.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "ERROR"
  }

  depends_on = [aws_api_gateway_account.apigw_account]
}
