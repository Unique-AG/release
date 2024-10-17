resource "azurerm_storage_account" "this" {
  name                             = module.context.full_name_no_dashes_truncated
  location                         = module.context.rg_app_sec.location
  resource_group_name              = module.context.rg_app_sec.name
  account_tier                     = "Premium"
  account_kind                     = "BlockBlobStorage"
  account_replication_type         = "LRS"
  min_tls_version                  = "TLS1_2"
  allow_nested_items_to_be_public  = false
  cross_tenant_replication_enabled = false
  https_traffic_only_enabled       = true
  nfsv3_enabled                    = true
  is_hns_enabled                   = true
  tags                             = module.context.tags
  lifecycle {
    ignore_changes = [
      customer_managed_key
    ]
  }
  identity {
    type = "SystemAssigned"
  }
  blob_properties {
    dynamic "container_delete_retention_policy" {
      for_each = var.storage_container_delete_retention_days > 0 ? [1] : []
      content {
        days = var.storage_container_delete_retention_days
      }
    }
    dynamic "delete_retention_policy" {
      for_each = var.storage_delete_retention_days > 0 ? [1] : []
      content {
        days                     = var.storage_delete_retention_days
        permanent_delete_enabled = false
      }
    }
  }
  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [var.subnet_nodes.id, var.subnet_pods.id]
    ip_rules                   = ["0.0.0.0/0"]
    private_link_access {
      endpoint_resource_id = "/subscriptions/${module.context.subscription_id}/providers/Microsoft.Security/datascanners/StorageDataScanner"
      endpoint_tenant_id   = module.context.tenant_id
    }
  }
}
resource "azurerm_storage_management_policy" "this" {
  storage_account_id = azurerm_storage_account.this.id
  rule {
    name    = "delete-older-than-${var.storage_retention_period_days}-days"
    enabled = true
    filters {
      blob_types = ["blockBlob"]
    }
    actions {
      base_blob {
        delete_after_days_since_creation_greater_than = var.storage_retention_period_days
      }
      snapshot {
        delete_after_days_since_creation_greater_than = var.storage_retention_period_days
      }
      version {
        delete_after_days_since_creation = var.storage_retention_period_days
      }
    }
  }
}
resource "azurerm_storage_container" "this" {
  for_each              = toset(var.audit_containers)
  name                  = each.value
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}
resource "azurerm_key_vault_secret" "storage-account-name" {
  name         = "storage-account-name"
  value        = azurerm_storage_account.this.name
  key_vault_id = azurerm_key_vault.this.id
}
resource "azurerm_key_vault_secret" "storage-account-resource-group" {
  name         = "resource-group-name"
  value        = module.context.rg_app_sec.name
  key_vault_id = azurerm_key_vault.this.id
}
resource "azurerm_key_vault_key" "this" {
  name         = "${module.context.full_name}-sa-hsm"
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
resource "azurerm_storage_account_customer_managed_key" "this" {
  storage_account_id = azurerm_storage_account.this.id
  key_vault_id       = azurerm_key_vault.this.id
  key_name           = azurerm_key_vault_key.this.name
}