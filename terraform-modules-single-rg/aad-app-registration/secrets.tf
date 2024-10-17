resource "azuread_application_password" "aad_app" {
  application_id = azuread_application.this.id
  display_name   = "unique-enterprise-app-key"
}
resource "azurerm_key_vault_secret" "aad_app_client_id" {
  name         = "aad-app-client-id"
  value        = azuread_application.this.client_id
  key_vault_id = var.keyvault_id
}
resource "azurerm_key_vault_secret" "aad_app_client_secret" {
  name         = "aad-app-client-secret"
  value        = azuread_application_password.aad_app.value
  key_vault_id = var.keyvault_id
}