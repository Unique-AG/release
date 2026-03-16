resource "azurerm_role_assignment" "rbac_keyvault_secret_users" {
  count                = length(var.keyvault_access_principals)
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.keyvault_access_principals[count.index]
}
resource "azurerm_key_vault" "this" {
  name                        = module.context.full_name
  location                    = module.context.rg_app_sec.location
  resource_group_name         = module.context.rg_app_sec.name
  enabled_for_disk_encryption = true
  tenant_id                   = module.context.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true
  enable_rbac_authorization   = true
  sku_name                    = "standard"
  tags                        = local.tags
}
resource "azurerm_monitor_diagnostic_setting" "kv_audit" {
  name                       = "audit-to-sentinel"
  target_resource_id         = azurerm_key_vault.this.id
  log_analytics_workspace_id = var.sentinel_log_analytics_workspace_id
  enabled_log {
    category = "AuditEvent"
  }
}