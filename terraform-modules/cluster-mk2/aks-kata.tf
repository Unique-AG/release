resource "azurerm_kubernetes_cluster_node_pool" "kata" {
  count                 = var.kata_node_pool.enabled ? 1 : 0
  name                  = var.kata_node_pool.name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  mode                  = "User"
  vm_size          = var.kata_node_pool.vm_size
  os_type          = "Linux"
  os_sku           = "AzureLinux"
  workload_runtime = "KataVmIsolation"
  os_disk_size_gb  = var.kata_node_pool.os_disk_size_gb
  max_pods         = var.kata_node_pool.max_pods
  zones            = var.kata_node_pool.zones
  auto_scaling_enabled = true
  min_count            = var.kata_node_pool.min_count
  max_count            = var.kata_node_pool.max_count
  vnet_subnet_id = var.subnet_nodes.id
  pod_subnet_id  = var.subnet_pods.id
  node_labels = {
    "workload-runtime" = "kata"
  }
  node_taints = ["workload-runtime=kata:NoSchedule"]
  temporary_name_for_rotation = "${var.kata_node_pool.name}repl"
  upgrade_settings {
    max_surge                     = var.kata_node_pool.max_surge
    drain_timeout_in_minutes      = var.kata_node_pool.drain_timeout_in_minutes
    node_soak_duration_in_minutes = var.kata_node_pool.node_soak_duration_in_minutes
    undrainable_node_behavior     = var.kata_node_pool.undrainable_node_behavior
  }
  tags = module.context.tags
  lifecycle {
    ignore_changes = [node_count]
  }
}