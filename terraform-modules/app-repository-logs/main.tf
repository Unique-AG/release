locals {
  truncated_name_max_length = 24
}
resource "azurerm_key_vault" "akv" {
  name                        = "kvsdkdpl${module.context.random_postfix}"
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
resource "azurerm_storage_account" "asa" {
  name                            = "sasdkdpl${module.context.random_postfix}"
  location                        = module.context.rg_app_main.location
  resource_group_name             = module.context.rg_app_main.name
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false
  min_tls_version                 = "TLS${replace(var.storage_account_min_tls_version, ".", "_")}"
  https_traffic_only_enabled      = true
  tags                            = module.context.tags
  identity {
    type = "SystemAssigned"
  }
  lifecycle {
    ignore_changes = [
      customer_managed_key
    ]
  }
}
resource "azurerm_storage_management_policy" "asmp" {
  storage_account_id = azurerm_storage_account.asa.id
  rule {
    name    = "delete-older-than-${var.storage_account_retention_period_days}-days"
    enabled = true
    filters {
      blob_types = ["blockBlob"]
    }
    actions {
      base_blob {
        delete_after_days_since_creation_greater_than = var.storage_account_retention_period_days
      }
      snapshot {
        delete_after_days_since_creation_greater_than = var.storage_account_retention_period_days
      }
      version {
        delete_after_days_since_creation = var.storage_account_retention_period_days
      }
    }
  }
}
resource "azurerm_key_vault_key" "akvk" {
  name         = "${module.context.full_name}-sa-hsm"
  key_vault_id = azurerm_key_vault.akv.id
  key_type     = "RSA-HSM"
  key_size     = var.storage_account_customer_managed_key_size
  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}
data "azurerm_storage_account" "dasa" {
  name                = azurerm_storage_account.asa.name
  resource_group_name = module.context.rg_app_main.name
  depends_on          = [azurerm_storage_account.asa]
}
resource "azurerm_role_assignment" "ara_sa" {
  for_each             = toset(["Key Vault Crypto User"])
  scope                = azurerm_key_vault.akv.id
  role_definition_name = each.value
  principal_id         = azurerm_storage_account.asa.identity.0.principal_id
}
resource "azurerm_role_assignment" "asa_ara_saklosr" {
  count              = length(var.sdk_deployment_service_principal_object_ids)
  scope              = azurerm_storage_account.asa.id
  role_definition_id = data.azurerm_role_definition.saklosr.id
  principal_id       = var.sdk_deployment_service_principal_object_ids[count.index]
}
resource "azurerm_storage_account_customer_managed_key" "asacmk" {
  storage_account_id = azurerm_storage_account.asa.id
  key_vault_id       = azurerm_key_vault.akv.id
  key_name           = azurerm_key_vault_key.akvk.name
  depends_on         = [azurerm_key_vault_key.akvk, azurerm_role_assignment.ara_sa]
}
resource "azurerm_role_assignment" "ara_access_principals" {
  count                = length(var.keyvault_access_principals)
  scope                = azurerm_key_vault.akv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.keyvault_access_principals[count.index]
}
resource "azurerm_key_vault_secret" "akvs_blob_endpoint" {
  name         = "blob-endpoint"
  value        = azurerm_storage_account.asa.primary_blob_endpoint
  key_vault_id = azurerm_key_vault.akv.id
}
resource "azurerm_key_vault_secret" "akvs_azure_subscription_id" {
  name         = "azure-subscription-id"
  value        = local.azure_subscription_id
  key_vault_id = azurerm_key_vault.akv.id
}
locals {
  azure_resource_group_name_logs = var.logs_destination_azure_resource_group_name != "" ? var.logs_destination_azure_resource_group_name : module.context.rg_app_main.name
  azure_subscription_id          = var.logs_destination_azure_subscription_id != "" ? var.logs_destination_azure_subscription_id : data.azurerm_subscription.this.subscription_id
}
resource "azurerm_key_vault_secret" "akvs_azure_resource_group_name" {
  name         = "azure-resource-group-name"
  value        = local.azure_resource_group_name_logs
  key_vault_id = azurerm_key_vault.akv.id
}
resource "azurerm_user_assigned_identity" "auai" {
  name                = "${module.context.full_name}-wid-logs-reader"
  location            = module.context.rg_app_main.location
  resource_group_name = module.context.rg_app_main.name
  tags                = module.context.tags
}
data "azurerm_role_definition" "ard_blob_data_reader" {
  role_definition_id = "2a2b9908-6ea1-4ae2-8e65-a410df84e7d1"
  scope              = azurerm_storage_account.asa.id
}
resource "azurerm_role_assignment" "ara_blob_data_reader" {
  scope              = azurerm_storage_account.asa.id
  role_definition_id = data.azurerm_role_definition.ard_blob_data_reader.id
  principal_id       = azurerm_user_assigned_identity.auai.principal_id
}
resource "azurerm_federated_identity_credential" "afic" {
  name                = "${module.context.full_name}-federated-wid-logs-reader"
  resource_group_name = module.context.rg_app_main.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.workload_identity.aks_oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.auai.id
  subject             = "system:serviceaccount:${var.workload_identity.namespace}:${var.workload_identity.service_name}"
}
resource "azurerm_key_vault_secret" "akvs_workload_identity_client_id" {
  name         = "wid-client-id-logs-reader"
  value        = azurerm_user_assigned_identity.auai.client_id
  key_vault_id = azurerm_key_vault.akv.id
}