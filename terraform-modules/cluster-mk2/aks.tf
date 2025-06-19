resource "azurerm_public_ip" "this" {
  name                = "${module.context.full_name}-lb"
  location            = module.context.rg_app_main.location
  resource_group_name = module.context.rg_app_main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
  tags                = module.context.tags
}
resource "azurerm_kubernetes_cluster" "this" {
  name                = module.context.full_name
  location            = module.context.rg_app_main.location
  resource_group_name = module.context.rg_app_main.name
  dns_prefix                          = module.context.full_name
  sku_tier                            = "Standard"
  cost_analysis_enabled               = var.kubernetes_cost_analysis_enabled
  automatic_upgrade_channel           = "stable"
  node_os_upgrade_channel             = "NodeImage"
  azure_policy_enabled                = true
  kubernetes_version                  = var.kubernetes_version
  local_account_disabled              = true
  oidc_issuer_enabled                 = true
  image_cleaner_enabled               = true
  image_cleaner_interval_hours        = 48
  workload_identity_enabled           = true
  private_cluster_enabled             = true
  private_dns_zone_id                 = "None"
  private_cluster_public_fqdn_enabled = true
  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
    load_balancer_profile {
      idle_timeout_in_minutes = 100
      outbound_ip_address_ids = [azurerm_public_ip.this.id]
    }
  }
  storage_profile {
    blob_driver_enabled = true
  }
  azure_active_directory_role_based_access_control {
    azure_rbac_enabled = true
    tenant_id          = module.context.tenant_id
  }
  workload_autoscaler_profile {
    keda_enabled                    = true
    vertical_pod_autoscaler_enabled = false
  }
  maintenance_window {
    allowed {
      day   = var.maintenance_window_day
      hours = range(var.maintenance_window_start, var.maintenance_window_end)
    }
  }
  auto_scaler_profile {
    max_graceful_termination_sec     = 4 * 3600 
    skip_nodes_with_local_storage    = false
    expander                         = "least-waste"
    scale_down_unneeded              = "5m"
    scale_down_utilization_threshold = 0.7
  }
  default_node_pool {
    name                        = "default"
    temporary_name_for_rotation = "defaultrepl"
    vm_size                     = var.kubernetes_default_node_size
    auto_scaling_enabled        = true
    min_count                   = var.kubernetes_default_node_count_min
    max_count                   = var.kubernetes_default_node_count_max
    os_disk_size_gb             = var.kubernetes_default_node_os_disk_size
    pod_subnet_id               = var.subnet_pods.id
    type                        = "VirtualMachineScaleSets"
    vnet_subnet_id              = var.subnet_nodes.id
    zones                       = ["1", "2", "3"]
    tags                        = module.context.tags
    upgrade_settings {
      max_surge = 1
    }
  }
  identity {
    type = "SystemAssigned"
  }
  oms_agent {
    log_analytics_workspace_id      = azurerm_log_analytics_workspace.this.id
    msi_auth_for_monitoring_enabled = true
  }
  microsoft_defender {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  }
  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }
  ingress_application_gateway {
    gateway_id = azurerm_application_gateway.appgw.id
  }
  dynamic "monitor_metrics" {
    for_each = var.azure_prometheus_grafana_monitor.enabled ? [1] : []
    content {
    }
  }
  tags = module.context.tags
  lifecycle {
    ignore_changes = [
      kubernetes_version
    ]
  }
}