resource "azurerm_monitor_data_collection_endpoint" "this" {
  count               = var.azure_prometheus_grafana_monitor.enabled ? 1 : 0
  name                = module.context.full_name
  resource_group_name = module.context.rg_app_main.name
  location            = var.azure_prometheus_grafana_monitor.azure_monitor_location
  kind                = "Linux"
  tags                = module.context.tags
}
resource "azurerm_resource_provider_registration" "azure_monitor_provider" {
  name = "Microsoft.Monitor"
}
resource "azurerm_monitor_workspace" "this" {
  count               = var.azure_prometheus_grafana_monitor.enabled ? 1 : 0
  name                = module.context.full_name
  resource_group_name = module.context.rg_app_main.name
  location            = var.azure_prometheus_grafana_monitor.azure_monitor_location
  tags                = module.context.tags
  depends_on = [
    azurerm_resource_provider_registration.azure_monitor_provider
  ]
}
resource "azurerm_monitor_data_collection_rule" "this" {
  count                       = var.azure_prometheus_grafana_monitor.enabled ? 1 : 0
  name                        = module.context.full_name
  resource_group_name         = module.context.rg_app_main.name
  location                    = var.azure_prometheus_grafana_monitor.azure_monitor_location
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.this[count.index].id
  kind                        = "Linux"
  tags                        = module.context.tags
  destinations {
    monitor_account {
      monitor_account_id = azurerm_monitor_workspace.this[count.index].id
      name               = "MonitoringAccount1"
    }
  }
  data_flow {
    streams      = ["Microsoft-PrometheusMetrics"]
    destinations = ["MonitoringAccount1"]
  }
  data_sources {
    prometheus_forwarder {
      streams = ["Microsoft-PrometheusMetrics"]
      name    = "PrometheusDataSource"
    }
  }
  description = "DCR for Azure Monitor Metrics Profile (Managed Prometheus)"
  depends_on = [
    azurerm_monitor_data_collection_endpoint.this
  ]
}
resource "azurerm_monitor_data_collection_rule_association" "this" {
  count                   = var.azure_prometheus_grafana_monitor.enabled ? 1 : 0
  name                    = module.context.full_name
  target_resource_id      = azurerm_kubernetes_cluster.this.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.this[count.index].id
  description             = "Association of data collection rule. Deleting this association will break the data collection for this AKS Cluster."
  depends_on = [
    azurerm_monitor_data_collection_rule.this
  ]
}
resource "azurerm_resource_provider_registration" "azure_dashboard_provider" {
  name = "Microsoft.Dashboard"
}
resource "azurerm_dashboard_grafana" "this" {
  count                 = var.azure_prometheus_grafana_monitor.enabled ? 1 : 0
  name                  = module.context.full_name
  resource_group_name   = module.context.rg_app_main.name
  grafana_major_version = var.azure_prometheus_grafana_monitor.grafana_major_version
  location              = var.azure_prometheus_grafana_monitor.azure_monitor_location
  tags                  = module.context.tags
  identity {
    type = "SystemAssigned"
  }
  azure_monitor_workspace_integrations {
    resource_id = azurerm_monitor_workspace.this[count.index].id
  }
  depends_on = [
    azurerm_resource_provider_registration.azure_dashboard_provider
  ]
}
data "azurerm_role_definition" "monitoringdatareader" {
  name = "Monitoring Data Reader"
}
resource "azurerm_role_assignment" "monitor_reader_grafana" {
  count              = var.azure_prometheus_grafana_monitor.enabled ? 1 : 0
  scope              = azurerm_monitor_workspace.this[count.index].id
  role_definition_id = "/subscriptions/${module.context.subscription_id}${data.azurerm_role_definition.monitoringdatareader.id}"
  principal_id       = azurerm_dashboard_grafana.this[count.index].identity.0.principal_id
}
resource "azurerm_monitor_alert_prometheus_rule_group" "node_recording_rules_rule_group" {
  count               = var.azure_prometheus_grafana_monitor.enabled ? 1 : 0
  name                = "${azurerm_kubernetes_cluster.this.name}-NodeRecordingRulesRuleGroup"
  resource_group_name = module.context.rg_app_main.name
  location            = var.azure_prometheus_grafana_monitor.azure_monitor_location
  cluster_name        = azurerm_kubernetes_cluster.this.name
  description         = "Node Recording Rules Rule Group"
  rule_group_enabled  = true
  interval            = "PT1M"
  scopes              = [azurerm_monitor_workspace.this[count.index].id, azurerm_kubernetes_cluster.this.id]
  tags                = module.context.tags
  rule {
    enabled    = true
    record     = "instance:node_num_cpu:sum"
    expression = <<EOF
count without (cpu, mode) (  node_cpu_seconds_total{job="node",mode="idle"})
EOF
  }
  rule {
    enabled    = true
    record     = "instance:node_cpu_utilisation:rate5m"
    expression = <<EOF
1 - avg without (cpu) (  sum without (mode) (rate(node_cpu_seconds_total{job="node", mode=~"idle|iowait|steal"}[5m])))
EOF
  }
  rule {
    enabled    = true
    record     = "instance:node_load1_per_cpu:ratio"
    expression = <<EOF
(  node_load1{job="node"}/  instance:node_num_cpu:sum{job="node"})
EOF
  }
  rule {
    enabled    = true
    record     = "instance:node_memory_utilisation:ratio"
    expression = <<EOF
1 - (  (    node_memory_MemAvailable_bytes{job="node"}    or    (      node_memory_Buffers_bytes{job="node"}      +      node_memory_Cached_bytes{job="node"}      +      node_memory_MemFree_bytes{job="node"}      +      node_memory_Slab_bytes{job="node"}    )  )/  node_memory_MemTotal_bytes{job="node"})
EOF
  }
  rule {
    enabled    = true
    record     = "instance:node_vmstat_pgmajfault:rate5m"
    expression = <<EOF
rate(node_vmstat_pgmajfault{job="node"}[5m])
EOF
  }
  rule {
    enabled    = true
    record     = "instance_device:node_disk_io_time_seconds:rate5m"
    expression = <<EOF
rate(node_disk_io_time_seconds_total{job="node", device!=""}[5m])
EOF
  }
  rule {
    enabled    = true
    record     = "instance_device:node_disk_io_time_weighted_seconds:rate5m"
    expression = <<EOF
rate(node_disk_io_time_weighted_seconds_total{job="node", device!=""}[5m])
EOF
  }
  rule {
    enabled    = true
    record     = "instance:node_network_receive_bytes_excluding_lo:rate5m"
    expression = <<EOF
sum without (device) (  rate(node_network_receive_bytes_total{job="node", device!="lo"}[5m]))
EOF
  }
  rule {
    enabled    = true
    record     = "instance:node_network_transmit_bytes_excluding_lo:rate5m"
    expression = <<EOF
sum without (device) (  rate(node_network_transmit_bytes_total{job="node", device!="lo"}[5m]))
EOF
  }
  rule {
    enabled    = true
    record     = "instance:node_network_receive_drop_excluding_lo:rate5m"
    expression = <<EOF
sum without (device) (  rate(node_network_receive_drop_total{job="node", device!="lo"}[5m]))
EOF
  }
  rule {
    enabled    = true
    record     = "instance:node_network_transmit_drop_excluding_lo:rate5m"
    expression = <<EOF
sum without (device) (  rate(node_network_transmit_drop_total{job="node", device!="lo"}[5m]))
EOF
  }
}
resource "azurerm_monitor_alert_prometheus_rule_group" "kubernetes_recording_rules_rule_group" {
  count               = var.azure_prometheus_grafana_monitor.enabled ? 1 : 0
  name                = "${azurerm_kubernetes_cluster.this.name}-KubernetesRecordingRulesRuleGroup"
  location            = var.azure_prometheus_grafana_monitor.azure_monitor_location
  resource_group_name = module.context.rg_app_main.name
  cluster_name        = azurerm_kubernetes_cluster.this.name
  description         = "Kubernetes Recording Rules Rule Group"
  rule_group_enabled  = true
  interval            = "PT1M"
  scopes              = [azurerm_monitor_workspace.this[count.index].id, azurerm_kubernetes_cluster.this.id]
  tags                = module.context.tags
  rule {
    enabled    = true
    record     = "node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate"
    expression = <<EOF
sum by (cluster, namespace, pod, container) (  irate(container_cpu_usage_seconds_total{job="cadvisor", image!=""}[5m])) * on (cluster, namespace, pod) group_left(node) topk by (cluster, namespace, pod) (  1, max by(cluster, namespace, pod, node) (kube_pod_info{node!=""}))
EOF
  }
  rule {
    enabled    = true
    record     = "node_namespace_pod_container:container_memory_working_set_bytes"
    expression = <<EOF
container_memory_working_set_bytes{job="cadvisor", image!=""}* on (namespace, pod) group_left(node) topk by(namespace, pod) (1,  max by(namespace, pod, node) (kube_pod_info{node!=""}))
EOF
  }
  rule {
    enabled    = true
    record     = "node_namespace_pod_container:container_memory_rss"
    expression = <<EOF
container_memory_rss{job="cadvisor", image!=""}* on (namespace, pod) group_left(node) topk by(namespace, pod) (1,  max by(namespace, pod, node) (kube_pod_info{node!=""}))
EOF
  }
  rule {
    enabled    = true
    record     = "node_namespace_pod_container:container_memory_cache"
    expression = <<EOF
container_memory_cache{job="cadvisor", image!=""}* on (namespace, pod) group_left(node) topk by(namespace, pod) (1,  max by(namespace, pod, node) (kube_pod_info{node!=""}))
EOF
  }
  rule {
    enabled    = true
    record     = "node_namespace_pod_container:container_memory_swap"
    expression = <<EOF
container_memory_swap{job="cadvisor", image!=""}* on (namespace, pod) group_left(node) topk by(namespace, pod) (1,  max by(namespace, pod, node) (kube_pod_info{node!=""}))
EOF
  }
  rule {
    enabled    = true
    record     = "cluster:namespace:pod_memory:active:kube_pod_container_resource_requests"
    expression = <<EOF
kube_pod_container_resource_requests{resource="memory",job="kube-state-metrics"}  * on (namespace, pod, cluster)group_left() max by (namespace, pod, cluster) (  (kube_pod_status_phase{phase=~"Pending|Running"} == 1))
EOF
  }
  rule {
    enabled    = true
    record     = "namespace_memory:kube_pod_container_resource_requests:sum"
    expression = <<EOF
sum by (namespace, cluster) (    sum by (namespace, pod, cluster) (        max by (namespace, pod, container, cluster) (          kube_pod_container_resource_requests{resource="memory",job="kube-state-metrics"}        ) * on(namespace, pod, cluster) group_left() max by (namespace, pod, cluster) (          kube_pod_status_phase{phase=~"Pending|Running"} == 1        )    ))
EOF
  }
  rule {
    enabled    = true
    record     = "cluster:namespace:pod_cpu:active:kube_pod_container_resource_requests"
    expression = <<EOF
kube_pod_container_resource_requests{resource="cpu",job="kube-state-metrics"}  * on (namespace, pod, cluster)group_left() max by (namespace, pod, cluster) (  (kube_pod_status_phase{phase=~"Pending|Running"} == 1))
EOF
  }
  rule {
    enabled    = true
    record     = "namespace_cpu:kube_pod_container_resource_requests:sum"
    expression = <<EOF
sum by (namespace, cluster) (    sum by (namespace, pod, cluster) (        max by (namespace, pod, container, cluster) (          kube_pod_container_resource_requests{resource="cpu",job="kube-state-metrics"}        ) * on(namespace, pod, cluster) group_left() max by (namespace, pod, cluster) (          kube_pod_status_phase{phase=~"Pending|Running"} == 1        )    ))
EOF
  }
  rule {
    enabled    = true
    record     = "cluster:namespace:pod_memory:active:kube_pod_container_resource_limits"
    expression = <<EOF
kube_pod_container_resource_limits{resource="memory",job="kube-state-metrics"}  * on (namespace, pod, cluster)group_left() max by (namespace, pod, cluster) (  (kube_pod_status_phase{phase=~"Pending|Running"} == 1))
EOF
  }
  rule {
    enabled    = true
    record     = "namespace_memory:kube_pod_container_resource_limits:sum"
    expression = <<EOF
sum by (namespace, cluster) (    sum by (namespace, pod, cluster) (        max by (namespace, pod, container, cluster) (          kube_pod_container_resource_limits{resource="memory",job="kube-state-metrics"}        ) * on(namespace, pod, cluster) group_left() max by (namespace, pod, cluster) (          kube_pod_status_phase{phase=~"Pending|Running"} == 1        )    ))
EOF
  }
  rule {
    enabled    = true
    record     = "cluster:namespace:pod_cpu:active:kube_pod_container_resource_limits"
    expression = <<EOF
kube_pod_container_resource_limits{resource="cpu",job="kube-state-metrics"}  * on (namespace, pod, cluster)group_left() max by (namespace, pod, cluster) ( (kube_pod_status_phase{phase=~"Pending|Running"} == 1) )
EOF
  }
  rule {
    enabled    = true
    record     = "namespace_cpu:kube_pod_container_resource_limits:sum"
    expression = <<EOF
sum by (namespace, cluster) (    sum by (namespace, pod, cluster) (        max by (namespace, pod, container, cluster) (          kube_pod_container_resource_limits{resource="cpu",job="kube-state-metrics"}        ) * on(namespace, pod, cluster) group_left() max by (namespace, pod, cluster) (          kube_pod_status_phase{phase=~"Pending|Running"} == 1        )    ))
EOF
  }
  rule {
    enabled    = true
    record     = "namespace_workload_pod:kube_pod_owner:relabel"
    expression = <<EOF
max by (cluster, namespace, workload, pod) (  label_replace(    label_replace(      kube_pod_owner{job="kube-state-metrics", owner_kind="ReplicaSet"},      "replicaset", "$1", "owner_name", "(.*)"    ) * on(replicaset, namespace) group_left(owner_name) topk by(replicaset, namespace) (      1, max by (replicaset, namespace, owner_name) (        kube_replicaset_owner{job="kube-state-metrics"}      )    ),    "workload", "$1", "owner_name", "(.*)"  ))
EOF
    labels = {
      workload_type = "deployment"
    }
  }
  rule {
    enabled    = true
    record     = "namespace_workload_pod:kube_pod_owner:relabel"
    expression = <<EOF
max by (cluster, namespace, workload, pod) (  label_replace(    kube_pod_owner{job="kube-state-metrics", owner_kind="DaemonSet"},    "workload", "$1", "owner_name", "(.*)"  ))
EOF
    labels = {
      workload_type = "daemonset"
    }
  }
  rule {
    enabled    = true
    record     = "namespace_workload_pod:kube_pod_owner:relabel"
    expression = <<EOF
max by (cluster, namespace, workload, pod) (  label_replace(    kube_pod_owner{job="kube-state-metrics", owner_kind="StatefulSet"},    "workload", "$1", "owner_name", "(.*)"  ))
EOF
    labels = {
      workload_type = "statefulset"
    }
  }
  rule {
    enabled    = true
    record     = "namespace_workload_pod:kube_pod_owner:relabel"
    expression = <<EOF
max by (cluster, namespace, workload, pod) (  label_replace(    kube_pod_owner{job="kube-state-metrics", owner_kind="Job"},    "workload", "$1", "owner_name", "(.*)"  ))
EOF
    labels = {
      workload_type = "job"
    }
  }
  rule {
    enabled    = true
    record     = ":node_memory_MemAvailable_bytes:sum"
    expression = <<EOF
sum(  node_memory_MemAvailable_bytes{job="node"} or  (    node_memory_Buffers_bytes{job="node"} +    node_memory_Cached_bytes{job="node"} +    node_memory_MemFree_bytes{job="node"} +    node_memory_Slab_bytes{job="node"}  )) by (cluster)
EOF
  }
  rule {
    enabled    = true
    record     = "cluster:node_cpu:ratio_rate5m"
    expression = <<EOF
sum(rate(node_cpu_seconds_total{job="node",mode!="idle",mode!="iowait",mode!="steal"}[5m])) by (cluster) /count(sum(node_cpu_seconds_total{job="node"}) by (cluster, instance, cpu)) by (cluster)
EOF
  }
}