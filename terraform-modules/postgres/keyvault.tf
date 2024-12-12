resource "azurerm_role_assignment" "rbac_keyvault_secret_users" {
  count                = length(var.keyvault_access_principals)
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.keyvault_access_principals[count.index]
}
resource "azurerm_role_assignment" "rbac_keyvault_postgres_user" {
  for_each             = toset(["Key Vault Secrets User", "Key Vault Crypto User"])
  scope                = azurerm_key_vault.this.id
  role_definition_name = each.value
  principal_id         = azurerm_user_assigned_identity.this.principal_id
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
  sku_name                    = "premium"
  tags                        = module.context.tags
}