resource "aws_cognito_identity_pool" "entraid" {
  identity_pool_name               = "entraid"
  allow_unauthenticated_identities = false
  allow_classic_flow               = false

  developer_provider_name = "entraid"
}

ephemeral "aws_cognito_identity_openid_token_for_developer_identity" "entraid" {
  identity_pool_id = aws_cognito_identity_pool.entraid.id
  logins = {
    "entraid" : var.entraid_credentials_name
  }
}
