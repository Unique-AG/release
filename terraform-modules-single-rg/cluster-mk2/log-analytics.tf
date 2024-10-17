locals {
  diagnostic_logs_all_categories = [
    "cloud-controller-manager",
    "cluster-autoscaler",
    "csi-azuredisk-controller",
    "csi-azurefile-controller",
    "csi-snapshot-controller",
    "kube-audit-admin",
    "kube-scheduler",
  ]
  basic_log_tables = [
    "ContainerLogV2",
    "AKSControlPlane",
  ]
}
resource "azurerm_log_analytics_workspace" "this" {
  name                = module.context.full_name
  location            = module.context.resource_group.location
  resource_group_name = module.context.resource_group.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_period
}
moved {
  from = azurerm_log_analytics_saved_search.container_logs_of_a_service_containing_a_keyword_basic_type[0]
  to   = azurerm_log_analytics_saved_search.container_logs_of_a_service_containing_a_keyword_basic_type
}
resource "azurerm_log_analytics_saved_search" "container_logs_of_a_service_containing_a_keyword_basic_type" {
  name                       = "Container Logs of a service containing a keyword (basic type)"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  category                   = "Custom"
  display_name               = "Container Logs of a service containing a keyword (basic type)"
  query                      = <<-EOT
ContainerLogV2
| where LogMessage contains "<search>" and PodName in ("<podName1>", "<podName2>")
| project TimeGenerated, PodNamespace, PodName, ContainerName, LogSource, LogMessage
  EOT
}
resource "azurerm_log_analytics_saved_search" "events_of_service" {
  name                       = "Container events of a specific service"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  category                   = "Custom"
  display_name               = "Container events of a specific service"
  query                      = <<-EOT
  let serviceName = "<servicename>";
  KubeEvents
  | where not(isempty(Namespace))
  | where Name startswith serviceName
  | sort by TimeGenerated desc
  | render table
  EOT
}
resource "azurerm_log_analytics_workspace_table" "basic_log_table" {
  for_each     = toset(local.basic_log_tables)
  workspace_id = azurerm_log_analytics_workspace.this.id
  name         = each.value
  plan         = "Basic"
}
resource "azurerm_monitor_diagnostic_setting" "main" {
  name                           = "aks-diagnostic-logs"
  target_resource_id             = azurerm_kubernetes_cluster.this.id
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.this.id
  log_analytics_destination_type = "Dedicated"
  dynamic "enabled_log" {
    for_each = local.diagnostic_logs_all_categories
    content {
      category = enabled_log.value
    }
  }
  metric {
    category = "AllMetrics"
    enabled  = false
  }
}