output "keyvault_id" {
  value = azurerm_key_vault.document-chat.id
}
output "storage_account_name" {
  description = "Name of the document/ingestion storage account (hosts the Conduct checkpoint file share)."
  value       = azurerm_storage_account.document-chat.name
}
output "endpoints" {
  value = jsonencode(local.merged_model_endpoints)
}
output "openai" {
  value = module.openai
}