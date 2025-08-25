resource "azurerm_storage_account" "document-chat" {
  name                            = module.context.full_name_no_dashes_truncated
  location                        = module.context.rg_app_sec.location
  resource_group_name             = module.context.rg_app_sec.name
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false
  min_tls_version                 = "TLS${replace(var.min_tls_version, ".", "_")}"
  https_traffic_only_enabled      = true
  tags                            = local.tags
  blob_properties {
    change_feed_enabled           = var.storage_account_change_feed_enabled
    change_feed_retention_in_days = var.storage_account_change_feed_retention_days > 0 ? var.storage_account_change_feed_retention_days : null
    versioning_enabled            = var.storage_account_versioning_enabled
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
    dynamic "container_delete_retention_policy" {
      for_each = var.storage_account_container_delete_retention_days > 0 ? [1] : []
      content {
        days = var.storage_account_container_delete_retention_days
      }
    }
    dynamic "delete_retention_policy" {
      for_each = var.storage_account_delete_retention_days > 0 ? [1] : []
      content {
        days                     = var.storage_account_delete_retention_days
        permanent_delete_enabled = false
      }
    }
    dynamic "restore_policy" {
      for_each = var.storage_account_restore_days > 0 ? [1] : []
      content {
        days = var.storage_account_restore_days
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
resource "azurerm_key_vault_secret" "storage-account-connection-string-1" {
  name         = "storage-account-connection-string-1"
  value        = azurerm_storage_account.document-chat.primary_connection_string
  key_vault_id = azurerm_key_vault.document-chat.id
}
resource "azurerm_key_vault_secret" "storage-account-connection-string-2" {
  name         = "storage-account-connection-string-2"
  value        = azurerm_storage_account.document-chat.secondary_connection_string
  key_vault_id = azurerm_key_vault.document-chat.id
}
resource "azurerm_key_vault_key" "storage-account-byok" {
  name         = "${module.context.full_name}-sa-hsm"
  key_vault_id = azurerm_key_vault.document-chat.id
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
resource "azurerm_storage_account_customer_managed_key" "this" {
  depends_on         = [azurerm_key_vault_key.storage-account-byok]
  storage_account_id = azurerm_storage_account.document-chat.id
  key_vault_id       = azurerm_key_vault.document-chat.id
  key_name           = azurerm_key_vault_key.storage-account-byok.name
}
resource "azurerm_storage_management_policy" "management_policy" {
  count              = var.storage_account_versioning_enabled ? 1 : 0
  storage_account_id = azurerm_storage_account.document-chat.id
  rule {
    name    = "DeletePreviousVersions"
    enabled = true
    filters {
      prefix_match = []
      blob_types   = ["appendBlob", "blockBlob"]
    }
    actions {
      version {
        delete_after_days_since_creation = var.storage_account_versioning_retention_days
      }
    }
  }
}
resource "azurerm_data_protection_backup_vault" "vault" {
  count                      = var.storage_account_backup_enabled ? 1 : 0
  name                       = module.context.full_name
  location                   = module.context.rg_app_sec.location
  resource_group_name        = module.context.rg_app_sec.name
  datastore_type             = "VaultStore"
  redundancy                 = var.storage_account_backup_redundancy
  retention_duration_in_days = var.storage_account_backup_retention_days
  soft_delete                = var.storage_account_backup_soft_delete ? "On" : "Off"
  tags                       = local.tags
  identity {
    type = "SystemAssigned"
  }
}
resource "azurerm_role_assignment" "role" {
  count                = var.storage_account_backup_enabled ? 1 : 0
  scope                = azurerm_storage_account.document-chat.id
  role_definition_name = "Storage Account Backup Contributor"
  principal_id         = azurerm_data_protection_backup_vault.vault[0].identity[0].principal_id
}
resource "azurerm_data_protection_backup_policy_blob_storage" "policy" {
  count                                  = var.storage_account_backup_enabled ? 1 : 0
  name                                   = module.context.full_name
  vault_id                               = azurerm_data_protection_backup_vault.vault[0].id
  operational_default_retention_duration = var.storage_account_backup_retention_duration
}
resource "azurerm_data_protection_backup_instance_blob_storage" "instance" {
  count              = var.storage_account_backup_enabled ? 1 : 0
  name               = module.context.full_name
  location           = module.context.rg_app_sec.location
  vault_id           = azurerm_data_protection_backup_vault.vault[0].id
  storage_account_id = azurerm_storage_account.document-chat.id
  backup_policy_id   = azurerm_data_protection_backup_policy_blob_storage.policy[0].id
  depends_on         = [azurerm_role_assignment.role[0]]
}