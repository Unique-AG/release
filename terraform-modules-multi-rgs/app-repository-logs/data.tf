data "azurerm_subscription" "this" {
  subscription_id = module.context.subscription_id
}
data "azurerm_role_definition" "saklosr" {
  role_definition_id = var.storage_account_key_list_operator_service_role_id
  scope              = data.azurerm_subscription.this.id
}