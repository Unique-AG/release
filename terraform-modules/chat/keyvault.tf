resource "azurerm_role_assignment" "rbac_keyvault_openai_user" {
  for_each             = toset(["Key Vault Secrets User", "Key Vault Crypto User"])
  scope                = azurerm_key_vault.document-chat.id
  role_definition_name = each.value
  principal_id         = azurerm_storage_account.document-chat.identity.0.principal_id
}
resource "azurerm_role_assignment" "rbac_keyvault_secret_users" {
  count                = length(var.keyvault_access_principals)
  scope                = azurerm_key_vault.document-chat.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.keyvault_access_principals[count.index]
}
data "azurerm_storage_account" "document-chat" {
  name                = azurerm_storage_account.document-chat.name
  resource_group_name = module.context.resource_group.name
}
resource "azurerm_key_vault" "document-chat" {
  name                        = module.context.full_name
  location                    = module.context.resource_group.location
  resource_group_name         = module.context.resource_group.name
  enabled_for_disk_encryption = true
  tenant_id                   = module.context.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true
  enable_rbac_authorization   = true
  sku_name                    = "premium"
  tags                        = local.tags
}
locals {
  all_model_endpoints    = concat(var.azure_openai_endpoints, [module.openai.endpoints])
  all_model_names        = distinct(flatten([for e in local.all_model_endpoints : keys(e)]))
  merged_model_endpoints = { for k in local.all_model_names : k => distinct(flatten([for e in local.all_model_endpoints : try(e[k], [])])) }
}
resource "azurerm_key_vault_secret" "azure-openai-endpoints-json" {
  name         = "azure-openai-endpoints-json"
  value        = jsonencode(local.merged_model_endpoints)
  key_vault_id = azurerm_key_vault.document-chat.id
}
resource "azurerm_key_vault_secret" "azure_document_intelligence_endpoints" {
  name         = "azure-document-intelligence-endpoints"
  value        = jsonencode(var.azure_document_intelligence_endpoints)
  key_vault_id = azurerm_key_vault.document-chat.id
}