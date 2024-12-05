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
  kind                  = "OpenAI"
  custom_subdomain_name = local.custom_subdomain_name
  sku_name              = "S0"
  tags                  = module.context.tags
  local_auth_enabled    = var.local_auth_enabled
  dynamic "identity" {
    for_each = length(var.user_assigned_identity_ids) > 0 ? [1] : []
    content {
      type         = "UserAssigned"
      identity_ids = var.user_assigned_identity_ids
    }
  }
}
locals {
  azurerm_key_vault_secret_prefix = var.key_vault_prefix != "" ? var.key_vault_prefix : module.context.name
}
resource "azurerm_key_vault_secret" "key" {
  count        = var.key_vault_id != "" ? 1 : 0
  name         = "${local.azurerm_key_vault_secret_prefix}-key"
  value        = azurerm_cognitive_account.this.primary_access_key
  key_vault_id = var.key_vault_id
}
resource "azurerm_key_vault_secret" "endpoint" {
  count        = var.key_vault_id != "" ? 1 : 0
  name         = "${local.azurerm_key_vault_secret_prefix}-endpoint"
  value        = azurerm_cognitive_account.this.endpoint
  key_vault_id = var.key_vault_id
}
resource "azurerm_cognitive_deployment" "models" {
  for_each               = var.deployments
  name                   = each.value.name
  cognitive_account_id   = azurerm_cognitive_account.this.id
  rai_policy_name        = each.value.rai_policy_name
  version_upgrade_option = "NoAutoUpgrade"
  model {
    format  = "OpenAI"
    name    = each.value.model_name
    version = each.value.model_version
  }
  scale {
    type     = each.value.sku_name
    capacity = each.value.sku_capacity
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