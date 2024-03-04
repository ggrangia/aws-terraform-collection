variable "role_name" {
  type        = string
  description = "Name of the role used by apigw resources"
}

variable "lambda_arns" {
  type        = list(string)
  description = "List of the lambda ARNs to be invoked"
}
