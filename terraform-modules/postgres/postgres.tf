locals {
  default_parameters = {
    max_connections    = 200
    "azure.extensions" = "PG_TRGM"
  }
}
resource "azurerm_user_assigned_identity" "this" {
  name                = module.context.full_name
  location            = module.context.resource_group.location
  resource_group_name = module.context.resource_group.name
}
resource "azurerm_private_dns_zone" "this" {
  name                = "${module.context.full_name}-pg.postgres.database.azure.com"
  resource_group_name = module.context.resource_group.name
}
resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  name                  = module.context.full_name
  private_dns_zone_name = azurerm_private_dns_zone.this.name
  virtual_network_id    = var.virtual_network_id
  resource_group_name   = module.context.resource_group.name
}
resource "azurerm_key_vault_key" "hsm" {
  name         = "${module.context.full_name}-pg-hsm"
  key_vault_id = azurerm_key_vault.this.id
  key_type     = "RSA-HSM"
  key_size     = 4096
  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}
resource "random_password" "postgres_username" {
  length  = 16
  special = false
}
resource "random_password" "postgres_password" {
  length  = 32
  special = false
}
resource "azurerm_postgresql_flexible_server" "this" {
  name                          = module.context.full_name
  location                      = module.context.resource_group.location
  resource_group_name           = module.context.resource_group.name
  version                       = var.flex_pg_version
  delegated_subnet_id           = var.delegated_subnet_id
  administrator_login           = random_password.postgres_username.result
  administrator_password        = random_password.postgres_password.result
  private_dns_zone_id           = azurerm_private_dns_zone.this.id
  public_network_access_enabled = false
  sku_name                      = var.flex_sku
  storage_mb                    = var.flex_storage_mb
  customer_managed_key {
    key_vault_key_id                  = azurerm_key_vault_key.hsm.id
    primary_user_assigned_identity_id = azurerm_user_assigned_identity.this.id
  }
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.this.id]
  }
  depends_on = [azurerm_private_dns_zone_virtual_network_link.this, azurerm_key_vault_key.hsm]
  tags       = module.context.tags
  lifecycle {
    ignore_changes = [
      zone,
    ]
  }
}
resource "azurerm_key_vault_secret" "host" {
  name         = "host"
  value        = azurerm_postgresql_flexible_server.this.fqdn
  key_vault_id = azurerm_key_vault.this.id
}
resource "azurerm_key_vault_secret" "port" {
  name         = "port"
  value        = "5432"
  key_vault_id = azurerm_key_vault.this.id
}
resource "azurerm_key_vault_secret" "username" {
  name         = "username"
  value        = random_password.postgres_username.result
  key_vault_id = azurerm_key_vault.this.id
}
resource "azurerm_key_vault_secret" "password" {
  name         = "password"
  value        = random_password.postgres_password.result
  key_vault_id = azurerm_key_vault.this.id
}
resource "azurerm_postgresql_flexible_server_configuration" "parameters" {
  for_each  = merge(local.default_parameters, var.parameters)
  server_id = azurerm_postgresql_flexible_server.this.id
  name      = each.key
  value     = each.value
}
resource "azurerm_monitor_diagnostic_setting" "pglog" {
  count                      = var.log_analytics_workspace_id != null ? 1 : 0
  name                       = module.context.full_name
  target_resource_id         = azurerm_postgresql_flexible_server.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  metric {
    category = "AllMetrics"
    enabled  = false
    retention_policy {
      days    = 0
      enabled = false
    }
  }
  dynamic "enabled_log" {
    for_each = [
      "PostgreSQLFlexSessions",
      "PostgreSQLFlexQueryStoreWaitStats",
      "PostgreSQLFlexQueryStoreRuntime",
      "PostgreSQLFlexTableStats",
    ]
    content {
      category = enabled_log.value
    }
  }
}