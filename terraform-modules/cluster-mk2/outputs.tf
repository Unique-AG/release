output "public_ip_address" {
  value = azurerm_public_ip.appgw.ip_address
}
output "dns_zone_name_servers" {
  value = azurerm_dns_zone.this.name_servers
}
output "aks_oidc_issuer_url" {
  value = azurerm_kubernetes_cluster.this.oidc_issuer_url
}
output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.this.id
}
output "key_vault_secrets_provider" {
  value = try(azurerm_kubernetes_cluster.this.key_vault_secrets_provider[0], null)
}
output "kubelet_identity_object_id" {
  description = "Object id of the managed identity used by kubelet (agent pool identity, image pulls)."
  value       = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}
output "cluster_identity_principal_id" {
  description = "Principal id of the cluster's system-assigned (control plane) identity. AKS uses it for the Azure Files / Disk CSI drivers when they provision volumes on storage accounts outside the node resource group."
  value       = azurerm_kubernetes_cluster.this.identity[0].principal_id
}
output "kata_node_pool_name" {
  description = "Name of the Conduct (Kata) node pool, null when disabled."
  value       = var.kata_node_pool.enabled ? azurerm_kubernetes_cluster_node_pool.kata[0].name : null
}
output "speech_service_private_dns_zone_id" {
  description = "ID of the speech service private DNS zone"
  value       = azurerm_private_dns_zone.speech_service_private_dns_zone.id
}