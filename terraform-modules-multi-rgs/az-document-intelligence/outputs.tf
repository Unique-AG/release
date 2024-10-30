output "endpoint" {
  value = azurerm_cognitive_account.this.endpoint
}
output "cognitive_account_id" {
  value = azurerm_cognitive_account.this.id
}
output "endpoint_definition" {
  value = {
    endpoint = azurerm_cognitive_account.this.endpoint
    location = var.account_location
  }
}