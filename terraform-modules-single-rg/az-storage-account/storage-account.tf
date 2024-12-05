resource "azurerm_storage_account" "this" {
  name                            = module.context.full_name_no_dashes_truncated
  location                        = module.context.resource_group.location
  resource_group_name             = module.context.resource_group.name
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false
  min_tls_version                 = "TLS${replace(var.min_tls_version, ".", "_")}"
  tags                            = module.context.tags
  blob_properties {
    dynamic "cors_rule" {
      for_each = var.storage_account_cors_rules
      content {
        allowed_origins    = cors_rule.value.allowed_origins
        allowed_methods    = cors_rule.value.allowed_methods
        allowed_headers    = cors_rule.value.allowed_headers
        exposed_headers    = cors_rule.value.exposed_headers
        max_age_in_seconds = cors_rule.value.max_age_in_seconds
      }
    }
  }
  identity {
    type = "SystemAssigned"
  }
  lifecycle {
    ignore_changes = [
      customer_managed_key
    ]
  }
}
resource "azurerm_storage_management_policy" "this" {
  count              = var.retention_period_days > 0 ? 1 : 0
  storage_account_id = azurerm_storage_account.this.id
  rule {
    name    = "delete-older-than-${var.retention_period_days}-days"
    enabled = true
    filters {
      blob_types = ["blockBlob"]
    }
    actions {
      base_blob {
        delete_after_days_since_creation_greater_than = var.retention_period_days
      }
      snapshot {
        delete_after_days_since_creation_greater_than = var.retention_period_days
      }
      version {
        delete_after_days_since_creation = var.retention_period_days
      }
    }
  }
}
resource "azurerm_key_vault_secret" "storage-account-connection-string-1" {
  name         = "storage-account-connection-string-1"
  value        = azurerm_storage_account.this.primary_connection_string
  key_vault_id = azurerm_key_vault.this.id
}
resource "azurerm_key_vault_secret" "storage-account-connection-string-2" {
  name         = "storage-account-connection-string-2"
  value        = azurerm_storage_account.this.secondary_connection_string
  key_vault_id = azurerm_key_vault.this.id
}
resource "azurerm_key_vault_key" "storage-account-byok" {
  name         = "${module.context.full_name}-sa-hsm"
  key_vault_id = azurerm_key_vault.this.id
  key_type     = "RSA-HSM"
  key_size     = var.customer_managed_key_size
  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}
resource "azurerm_storage_account_customer_managed_key" "this" {
  storage_account_id = azurerm_storage_account.this.id
  key_vault_id       = azurerm_key_vault.this.id
  key_name           = azurerm_key_vault_key.storage-account-byok.name
  depends_on         = [azurerm_key_vault_key.storage-account-byok, azurerm_role_assignment.rbac_keyvault_managed_identity]
}