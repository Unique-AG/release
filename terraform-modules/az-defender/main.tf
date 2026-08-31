resource "azurerm_security_center_subscription_pricing" "cspm_free" {
  count         = var.enable_cspm && !var.cspm_full ? 1 : 0
  tier          = "Free"
  resource_type = "CloudPosture"
}
resource "azurerm_security_center_subscription_pricing" "cspm_full" {
  count         = var.enable_cspm && var.cspm_full ? 1 : 0
  resource_type = "CloudPosture"
  tier          = "Standard"
  extension {
    name = "ContainerRegistriesVulnerabilityAssessments"
  }
  extension {
    name = "AgentlessVmScanning"
    additional_extension_properties = {
      ExclusionTags = var.vm_exclusion_tags
    }
  }
  extension {
    name = "AgentlessDiscoveryForKubernetes"
  }
  extension {
    name = "SensitiveDataDiscovery"
  }
  extension {
    name = "EntraPermissionsManagement"
  }
}
resource "azurerm_security_center_subscription_pricing" "cwp_storage" {
  count         = var.enable_cwp_storage ? 1 : 0
  resource_type = "StorageAccounts"
  tier          = "Standard"
  subplan       = "DefenderForStorageV2"
  extension {
    name = "OnUploadMalwareScanning"
    additional_extension_properties = {
      AutomatedResponse              = "None"
      BlobScanResultsOptions         = "BlobIndexTags"
      CapGBPerMonthPerStorageAccount = var.cwp_storage_cap_gb
    }
  }
  extension {
    name = "SensitiveDataDiscovery"
  }
}
resource "azurerm_security_center_subscription_pricing" "cwp_servers" {
  count         = var.enable_cwp_servers ? 1 : 0
  resource_type = "VirtualMachines"
  tier          = "Standard"
  subplan       = "P2"
  extension {
    name = "AgentlessVmScanning"
    additional_extension_properties = {
      ExclusionTags = var.vm_exclusion_tags
    }
  }
}
resource "azurerm_security_center_subscription_pricing" "cwp_keyvaults" {
  count         = var.enable_cwp_keyvaults ? 1 : 0
  resource_type = "KeyVaults"
  tier          = "Standard"
  subplan       = "PerKeyVault"
}
resource "azurerm_security_center_subscription_pricing" "cwp_resourcemanager" {
  count         = var.enable_cwp_resourcemanager ? 1 : 0
  resource_type = "Arm"
  tier          = "Standard"
  subplan       = "PerSubscription"
}
resource "azurerm_security_center_subscription_pricing" "cwp_opensourcerelationaldb" {
  count         = var.enable_cwp_opensourcerelationaldb ? 1 : 0
  resource_type = "OpenSourceRelationalDatabases"
  tier          = "Standard"
}
resource "azapi_resource" "security_contact" {
  count                     = var.enable_security_contact ? 1 : 0
  type                      = "Microsoft.Security/securityContacts@2023-12-01-preview"
  name                      = "default"
  parent_id                 = "/subscriptions/${module.context.subscription_id}"
  location                  = "westeurope"
  schema_validation_enabled = false
  body = {
    properties = {
      emails    = var.security_contact_email
      phone     = ""
      isEnabled = true
      notificationsByRole = {
        state = "On"
        roles = ["Owner"]
      }
      notificationsSources = [
        {
          sourceType       = "AttackPath"
          minimalRiskLevel = "Critical"
        },
        {
          sourceType      = "Alert"
          minimalSeverity = "High"
        }
      ]
    }
  }
}