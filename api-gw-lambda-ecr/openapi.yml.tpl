openapi: 3.0.1
x-original-swagger-version: "2.0"
# https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-swagger-extensions.html
info:
  title: My API v1
  description: My API Gateway v1.
  version: 1.0.0
servers:
  - url: example.com # pass here your custom domain
paths:
  /endpoint/v1/hello:
    get:
      summary: One of my wonderful endpoint
      parameters:
        - $ref: "#/components/parameters/authorization"
      x-amazon-apigateway-integration:
        type: aws_proxy
        httpMethod: POST # <--- always POST if using aws_proxy (lambda proxy). It is independent from you path method
        uri: ${endpoint_api1_lambda}
        credentials: ${endpoint_api1_role}
      security:
        - authorizerRandom: []

      responses:
        "200":
          description: Everything went fine
          content:
            application/json:
              schema:
                type: object
                required:
                  - message
                properties:
                  message:
                    type: string
                    example: "Well done!"
              example:
                message: "Well done!"
        "401":
          $ref: "#/components/responses/401Unauthorized"
        "403":
          $ref: "#/components/responses/403Forbidden"

components:
  #--------------------
  # Resusable schemas
  #--------------------

  parameters:
    authorization:
      in: header
      name: mykey
      schema:
        type: string
      required: true

  #-------------------------------
  # Reusable responses
  #-------------------------------
  responses:
    401Unauthorized:
      description: "Unauthorized"
      content:
        application/json:
          schema:
            type: object
            properties:
              message:
                type: string
                description: Error type
                enum: [Unauthorized]
                example: Unauthorized
            example:
              message: Unauthorized
    403Forbidden:
      description: "Forbidden"
      content:
        application/json:
          schema:
            type: object
            properties:
              message:
                type: string
                description: Error type
                enum: [Forbidden]
            example:
              message: Forbidden

  securitySchemes:
    authorizerRandom:
      name: authorizerRandom
      type: apiKey
      in: header
      x-amazon-apigateway-authtype: Custom scheme with corporate claims
      x-amazon-apigateway-authorizer:
        type: request
        authorizerUri: ${authorizer_lambda}
        authorizerCredentials: ${authorizer_credentials}
        authorizerResultTtlInSeconds: 0
        authorizerPayloadFormatVersion: "1.0"
        identitySource: "method.request.header.mykey"
