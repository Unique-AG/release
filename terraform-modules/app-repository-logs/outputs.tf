output "storage_account_id" {
  description = "ID of the Storage Account where the Monitor writes logs to."
  value       = azurerm_storage_account.asa.id
}