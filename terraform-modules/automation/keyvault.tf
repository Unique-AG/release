resource "azurerm_key_vault" "this" {
  name                        = module.context.full_name_truncated
  location                    = module.context.resource_group.location
  resource_group_name         = module.context.resource_group.name
  enabled_for_disk_encryption = true
  tenant_id                   = module.context.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true
  enable_rbac_authorization   = true
  sku_name                    = "standard"
  tags                        = module.context.tags
}
resource "azurerm_role_assignment" "rbac_keyvault_secret_users" {
  count                = length(var.keyvault_access_principals)
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.keyvault_access_principals[count.index]
}
resource "azurerm_key_vault_secret" "rabbitmq-username" {
  name         = "rabbitmq-username"
  value        = module.context.project
  key_vault_id = azurerm_key_vault.this.id
}
resource "random_password" "rabbitmq-password" {
  keepers = {
    version = "1"
  }
  length  = 24
  special = false
}
resource "azurerm_key_vault_secret" "rabbitmq-password" {
  name         = "rabbitmq-password"
  value        = random_password.rabbitmq-password.result
  key_vault_id = azurerm_key_vault.this.id
}
resource "azurerm_key_vault_secret" "rabbitmq-url" {
  name         = "rabbitmq-url"
  value        = "amqp://${module.context.project}:${random_password.rabbitmq-password.result}@rabbitmq-headless.system.svc.cluster.local:${var.rabbitmq-port}/%2f"
  key_vault_id = azurerm_key_vault.this.id
}
resource "random_password" "rabbitmq-erlang-cookie" {
  keepers = {
    version = "1"
  }
  length  = 32
  special = false
}
resource "azurerm_key_vault_secret" "rabbitmq-erlang-cookie" {
  name         = "rabbitmq-erlang-cookie"
  value        = random_password.rabbitmq-erlang-cookie.result
  key_vault_id = azurerm_key_vault.this.id
}
resource "random_password" "zitadel-main-key" {
  keepers = {
    version = "1"
  }
  length  = 32
  special = false
}
resource "azurerm_key_vault_secret" "argocd-secrets-list" {
  for_each     = var.argocd-secrets-list
  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.this.id
}
resource "azurerm_key_vault_secret" "zitadel-main-key" {
  name         = "zitadel-main-key"
  value        = random_password.zitadel-main-key.result
  key_vault_id = azurerm_key_vault.this.id
}
resource "random_password" "zitadel-zitadel-password" {
  keepers = {
    version = "1"
  }
  length  = 32
  special = false
}
resource "azurerm_key_vault_secret" "zitadel-zitadel-password" {
  name         = "zitadel-zitadel-password"
  value        = random_password.zitadel-zitadel-password.result
  key_vault_id = azurerm_key_vault.this.id
}
resource "random_password" "tyk-api-secret" {
  keepers = {
    version = "1"
  }
  length  = 24
  special = false
}
resource "azurerm_key_vault_secret" "tyk-api-secret" {
  name         = "tyk-api-secret"
  value        = random_password.tyk-api-secret.result
  key_vault_id = azurerm_key_vault.this.id
}
resource "azurerm_key_vault_secret" "placeholders" {
  for_each     = { for idx, secret in var.keyvault_secret_placeholders : secret => secret }
  name         = each.value
  value        = "<TO BE SET MANUALLY>"
  key_vault_id = azurerm_key_vault.this.id
  lifecycle {
    ignore_changes = [value, tags]
  }
}