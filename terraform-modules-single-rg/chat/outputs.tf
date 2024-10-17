output "keyvault_id" {
  value = azurerm_key_vault.document-chat.id
}
output "endpoints" {
  value = jsonencode(local.merged_model_endpoints)
}
output "app_repository_logs_storage_account_id" {
  value = module.app-repository-logs.storage_account_id
}
output "openai" {
  value = module.openai
}