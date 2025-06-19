output "endpoint" {
  value = azurerm_cognitive_account.this.endpoint
}
output "cognitive_account_id" {
  value = azurerm_cognitive_account.this.id
}
output "endpoints" {
  value = { for deployment in var.deployments : "${deployment.model_name}-${deployment.model_version}" => [azurerm_cognitive_account.this.endpoint] }
}
output "model_list" {
  value = {
    key      = azurerm_cognitive_account.this.primary_access_key
    endpoint = azurerm_cognitive_account.this.endpoint
    location = var.account_location
    models = [
      for deployment in var.deployments : {
        modelName      = deployment.model_name
        deploymentName = deployment.name
        modelVersion   = deployment.model_version
      }
    ]
  }
}