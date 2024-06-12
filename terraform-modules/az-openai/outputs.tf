output "endpoint" {
  value = azurerm_cognitive_account.this.endpoint
}
output "cognitive_account_id" {
  value = azurerm_cognitive_account.this.id
}
output "endpoints" {
  value = { for deployment in var.deployments : "${deployment.model_name}-${deployment.model_version}" => [azurerm_cognitive_account.this.endpoint] }
}