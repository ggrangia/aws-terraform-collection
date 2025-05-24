data "terraform_remote_state" "cognito" {
  backend = "local"

  config = {
    path = "../10_aws_cognito_identity_pool/terraform.tfstate"
  }
}
