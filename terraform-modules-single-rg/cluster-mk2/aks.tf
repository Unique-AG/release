resource "azurerm_public_ip" "this" {
  name                = "${module.context.full_name}-lb"
  location            = module.context.resource_group.location
  resource_group_name = module.context.resource_group.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
}
resource "azurerm_kubernetes_cluster" "this" {
  name                                = module.context.full_name
  location                            = module.context.resource_group.location
  resource_group_name                 = module.context.resource_group.name
  dns_prefix                          = module.context.full_name
  sku_tier                            = "Standard"
  cost_analysis_enabled               = var.kubernetes_cost_analysis_enabled
  automatic_channel_upgrade           = "stable"
  node_os_channel_upgrade             = "NodeImage"
  azure_policy_enabled                = true
  kubernetes_version                  = var.kubernetes_version
  local_account_disabled              = true
  oidc_issuer_enabled                 = true
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
    disk_driver_version = "v1"
  }
  azure_active_directory_role_based_access_control {
    managed            = true
    azure_rbac_enabled = true
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
  dynamic "maintenance_window_node_os" {
    for_each = var.maintenance_window_node_os != null ? [1] : []
    content {
      frequency   = var.maintenance_window_node_os.frequency
      interval    = var.maintenance_window_node_os.interval
      duration    = var.maintenance_window_node_os.duration
      day_of_week = var.maintenance_window_node_os.day_of_week
      start_time  = var.maintenance_window_node_os.start_time
      utc_offset  = var.maintenance_window_node_os.utc_offset
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
    enable_auto_scaling         = true
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
resource "azurerm_kubernetes_cluster_node_pool" "node_pool" {
  for_each              = var.user_node_pools
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  name                  = each.key
  vm_size               = each.value.vm_size
  node_count            = each.value.node_count
  enable_auto_scaling   = each.value.auto_scaling_enabled
  min_count             = each.value.min_count
  max_count             = each.value.max_count
  os_disk_size_gb       = each.value.os_disk_size_gb
  mode                  = "User"
  node_labels           = each.value.node_labels
  zones                 = each.value.zones
  node_taints           = each.value.node_taints
  os_sku                = each.value.os_sku
  upgrade_settings {
    max_surge = each.value.upgrade_settings.max_surge
  }
  tags           = var.tags
  pod_subnet_id  = var.subnet_pods.id
  vnet_subnet_id = var.subnet_nodes.id
}