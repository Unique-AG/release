resource "random_pet" "this" {
  length = 1
  keepers = {
    name = module.context.full_name
  }
}
locals {
  account_name          = coalesce(var.account_name, "${module.context.full_name}-${random_pet.this.id}")
  custom_subdomain_name = coalesce(var.custom_subdomain_name, "${module.context.full_name}-${random_pet.this.id}")
}
resource "azurerm_cognitive_account" "this" {
  name                  = local.account_name
  location              = var.account_location
  resource_group_name   = module.context.resource_group.name
  kind                  = "FormRecognizer"
  custom_subdomain_name = local.custom_subdomain_name
  sku_name              = "S0"
  tags                  = module.context.tags
  dynamic "identity" {
    for_each = length(var.user_assigned_identity_ids) > 0 ? [1] : []
    content {
      type         = "UserAssigned"
      identity_ids = var.user_assigned_identity_ids
    }
  }
}
resource "azurerm_monitor_diagnostic_setting" "diagnostic_setting" {
  count                      = var.log_analytics_workspace_id != "" ? 1 : 0
  name                       = module.context.full_name_truncated
  target_resource_id         = azurerm_cognitive_account.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  enabled_log {
    category_group = "audit"
  }
  metric {
    category = "AllMetrics"
    enabled  = false
  }
}