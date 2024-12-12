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
  resource_group_name = module.context.rg_app_sec.name
}
resource "azurerm_key_vault" "document-chat" {
  name                        = module.context.full_name
  location                    = module.context.rg_app_sec.location
  resource_group_name         = module.context.rg_app_sec.name
  enabled_for_disk_encryption = true
  tenant_id                   = module.context.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true
  enable_rbac_authorization   = true
  sku_name                    = "premium"
  tags                        = local.tags
}
resource "random_id" "ingestion_encryption_key" {
  byte_length = 32
  keepers = {
    version = var.ingestion_encryption_key_version
  }
}
resource "azurerm_key_vault_secret" "ingestion_encryption_key" {
  name         = "ingestion-encryption-key"
  value        = random_id.ingestion_encryption_key.hex
  key_vault_id = azurerm_key_vault.document-chat.id
}
resource "random_id" "chat_lxm_encryption_key" {
  byte_length = 32
  keepers = {
    version = var.chat_lxm_encryption_key_version
  }
}
resource "azurerm_key_vault_secret" "chat_lxm_encryption_key" {
  name         = "chat-lxm-encryption-key"
  value        = random_id.chat_lxm_encryption_key.hex
  key_vault_id = azurerm_key_vault.document-chat.id
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
resource "azurerm_key_vault_secret" "azure_document_intelligence_endpoint_definitions" {
  name         = "azure-document-intelligence-endpoint-definitions"
  value        = jsonencode(var.azure_document_intelligence_endpoint_definitions)
  key_vault_id = azurerm_key_vault.document-chat.id
}
resource "azurerm_key_vault_secret" "azure_websearch_api_url" {
  name         = "websearch-api-url"
  value        = jsondecode(azurerm_resource_group_template_deployment.argtd_bing_search_v7.output_content).endpoint.value
  key_vault_id = azurerm_key_vault.document-chat.id
}
resource "azurerm_key_vault_secret" "azure_websearch_subscription_key" {
  name         = "websearch-subscription-key"
  value        = jsondecode(azurerm_resource_group_template_deployment.argtd_bing_search_v7.output_content).accessKeys.value.key1
  key_vault_id = azurerm_key_vault.document-chat.id
}
locals {
  database_keyvault_id_enabled = var.database_keyvault_id != null ? true : false
}
data "azurerm_key_vault_secret" "host" {
  count        = local.database_keyvault_id_enabled ? 1 : 0
  name         = "host"
  key_vault_id = var.database_keyvault_id
}
data "azurerm_key_vault_secret" "username" {
  count        = local.database_keyvault_id_enabled ? 1 : 0
  name         = "username"
  key_vault_id = var.database_keyvault_id
}
data "azurerm_key_vault_secret" "password" {
  count        = local.database_keyvault_id_enabled ? 1 : 0
  name         = "password"
  key_vault_id = var.database_keyvault_id
}
resource "azurerm_key_vault_secret" "database_url" {
  for_each     = { for k in toset(local.dbs) : k => k if local.database_keyvault_id_enabled }
  name         = "database-url-${each.key}"
  value        = "postgresql://${data.azurerm_key_vault_secret.username[0].value}:${data.azurerm_key_vault_secret.password[0].value}@${data.azurerm_key_vault_secret.host[0].value}/${each.key}"
  key_vault_id = var.database_keyvault_id
}