resource "azurerm_security_center_subscription_pricing" "cspm_free" {
  count         = var.cspm_full ? 0 : 1
  tier          = "Free"
  resource_type = "CloudPosture"
}
resource "azurerm_security_center_subscription_pricing" "cspm_full" {
  count         = var.cspm_full ? 1 : 0
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
  extension {
    name = "ApiPosture"
  }
}
resource "azurerm_security_center_auto_provisioning" "auto_provisioning" {
  count          = var.enable_auto_provisioning ? 1 : 0
  auto_provision = "On"
}
resource "azurerm_security_center_subscription_pricing" "cwp_storage" {
  resource_type = "StorageAccounts"
  tier          = "Standard"
  subplan       = "DefenderForStorageV2"
  extension {
    name = "OnUploadMalwareScanning"
    additional_extension_properties = {
      CapGBPerMonthPerStorageAccount = var.cwp_storage_cap_gb
    }
  }
  extension {
    name = "SensitiveDataDiscovery"
  }
}
resource "azurerm_security_center_subscription_pricing" "cwp_servers" {
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
  resource_type = "KeyVaults"
  tier          = "Standard"
  subplan       = "PerKeyVault"
}
resource "azurerm_security_center_subscription_pricing" "cwp_resourcemanager" {
  resource_type = "Arm"
  tier          = "Standard"
  subplan       = "PerSubscription"
}
resource "azurerm_security_center_subscription_pricing" "cwp_opensourcerelationaldb" {
  resource_type = "OpenSourceRelationalDatabases"
  tier          = "Standard"
}
resource "azurerm_security_center_subscription_pricing" "cwp_containers" {
  tier          = "Standard"
  resource_type = "Containers"
  extension {
    name = "ContainerRegistriesVulnerabilityAssessments"
  }
  extension {
    name = "AgentlessDiscoveryForKubernetes"
  }
  extension {
    name = "ContainerSensor"
  }
  extension {
    name = "AgentlessVmScanning"
    additional_extension_properties = {
      ExclusionTags = "[]"
    }
  }
}
resource "azapi_resource" "security_contact" {
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