resource "aws_api_gateway_rest_api" "example" {
  body = jsonencode({
    openapi = "3.0.1"
    info = {
      title   = "example"
      version = "1.0"
    }
    paths = {
      "/v1/path2" = {
        get = {
          x-amazon-apigateway-integration = {
            type = "aws_proxy"
            uri  = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${module.hello_api.lambda_function_arn}/invocations"
            #uri        = module.hello_api.lambda_function_qualified_invoke_arn
            #uri        = module.alias_v1.lambda_alias_invoke_arn
            httpMethod = "GET"
          }
        }
      },
      "/v2/path2" : {
        get = {
          x-amazon-apigateway-integration = {
            httpMethod           = "GET"
            payloadFormatVersion = "1.0"
            type                 = "HTTP_PROXY"
            uri                  = "https://ip-ranges.amazonaws.com/ip-ranges.json"
          }
        }
      }
    }
  })

  name = "example"

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
