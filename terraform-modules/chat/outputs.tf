output "keyvault_id" {
  value = azurerm_key_vault.document-chat.id
}
output "endpoints" {
  value = jsonencode(local.merged_model_endpoints)
}
output "openai" {
  value = module.openai
}