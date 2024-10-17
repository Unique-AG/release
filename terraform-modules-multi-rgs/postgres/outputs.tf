output "server_id" {
  value = azurerm_postgresql_flexible_server.this.id
}
output "database_keyvault_id" {
  value = azurerm_key_vault.this.id
}