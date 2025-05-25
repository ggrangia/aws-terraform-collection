data "azuread_client_config" "current" {}

output "tenant_id" {
  value = data.azuread_client_config.current.tenant_id
}

output "entraid_application_tenantid" {
  value = azuread_application_registration.aws_integration.client_id
}
