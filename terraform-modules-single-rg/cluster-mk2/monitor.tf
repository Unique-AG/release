resource "azurerm_monitor_metric_alert" "appgw_5xx" {
  count               = var.azure_alerts.appgw.enabled ? 1 : 0
  name                = "${module.context.full_name}-appgw-5xx"
  resource_group_name = module.context.resource_group.name
  scopes              = [azurerm_application_gateway.appgw.id]
  description         = "Action will be triggered if there are more than 0 failed requests (5xx) on the Application Gateway."
  severity            = "0"
  frequency           = "PT5M"
  criteria {
    metric_namespace = "microsoft.network/applicationgateways"
    metric_name      = "ResponseStatus"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 8
    dimension {
      name     = "HttpStatusGroup"
      operator = "StartsWith"
      values = [
        "5xx",
      ]
    }
  }
  dynamic "action" {
    for_each = var.azure_alerts.appgw != null ? [1] : []
    content {
      action_group_id = var.azure_alerts.appgw.action_group_id
    }
  }
  tags = module.context.tags
}
resource "azurerm_monitor_data_collection_rule" "ci_dcr" {
  name                = "${module.context.full_name}-ci-dcr"
  resource_group_name = module.context.resource_group.name
  location            = module.context.resource_group.location
  tags                = module.context.tags
  kind                = "Linux"
  destinations {
    log_analytics {
      name                  = "ciworkspace"
      workspace_resource_id = azurerm_log_analytics_workspace.this.id
    }
  }
  data_flow {
    streams      = ["Microsoft-ContainerInsights-Group-Default"]
    destinations = ["ciworkspace"]
  }
  data_sources {
    extension {
      name           = "ContainerInsightsExtension"
      streams        = ["Microsoft-ContainerInsights-Group-Default"]
      extension_name = "ContainerInsights"
      extension_json = jsonencode({
        dataCollectionSettings = {
          interval               = "10m"
          namespaceFilteringMode = "Exclude"
          namespaces = [
            "kube-system",
            "gatekeeper-system",
            "azure-arc"
          ]
          enableContainerLogV2 = true
        }
      })
    }
  }
}
resource "azurerm_monitor_data_collection_rule_association" "ci_dcr_asc" {
  name                    = "${module.context.full_name}-ci-dcr-asc"
  target_resource_id      = azurerm_kubernetes_cluster.this.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.ci_dcr.id
}