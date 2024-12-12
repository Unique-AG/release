resource "azurerm_role_assignment" "this_access_principals" {
  count                = length(var.keyvault_access_principals)
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.keyvault_access_principals[count.index]
}
resource "azurerm_role_assignment" "rbac_keyvault_managed_identity" {
  for_each             = toset(["Key Vault Crypto User"])
  scope                = azurerm_key_vault.this.id
  role_definition_name = each.value
  principal_id         = azurerm_storage_account.this.identity.0.principal_id
}
data "azurerm_storage_account" "this" {
  name                = azurerm_storage_account.this.name
  resource_group_name = module.context.rg_app_sec.name
}
resource "azurerm_key_vault" "this" {
  name                        = replace(module.context.full_name_truncated, "--", "-")
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