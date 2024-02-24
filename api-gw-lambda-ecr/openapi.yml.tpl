openapi: 3.0.1
x-original-swagger-version: "2.0"
info:
  title: My API v1
  description: My API Gateway v1.
  version: 1.0.0
servers:
  - url: ${server_url}
paths:
  /endpoint/api1:
    get:
      summary: One of my wonderful endpoint
      parameters:
        - $ref: "#/components/parameters/x-api-key"
      x-amazon-apigateway-integration:
        type: aws_proxy
        httpMethod: POST # <--- always POST if using aws_proxy (lambda proxy). It is independent from you path method
        uri: ${endpoint_api1_lambda}
        credentials: ${endpoint_api1_role}
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

  /endpoint/api2:
    get:
      summary: Another wonderful endpoint
      parameters:
        - $ref: "#/components/parameters/x-api-key"
      x-amazon-apigateway-integration:
        type: aws_proxy
        httpMethod: POST # <--- always POST if using aws_proxy (lambda proxy). It is independent from you path method
        uri: ${endpoint_api2_lambda}
        credentials: ${endpoint_api2_role}
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
    x-api-key:
      in: header
      name: x-api-key
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
