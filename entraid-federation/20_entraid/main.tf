resource "azuread_application_registration" "aws_integration" {
  display_name = "AWS Integration"
  description  = "This application authenticate workloads on AWS"
}

resource "azuread_application_federated_identity_credential" "aws_integration" {
  application_id = azuread_application_registration.aws_integration.id
  display_name   = var.entraid_credentials_name
  description    = "Federation with AWS Identity Pools created in this example"
  audiences      = [data.terraform_remote_state.cognito.outputs.cognito_pool_id]
  # If not in us-east-1, it might have the region before amazonaws.com. Check the issuer from the token itself
  issuer  = "https://cognito-identity.amazonaws.com"
  subject = "add-here-cognito-identity-id" # Add here the aws cognito identity id  e.g. "{region}:{uuid}"
}
