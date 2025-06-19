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
output "speech_service_private_dns_zone_id" {
  description = "ID of the speech service private DNS zone"
  value       = azurerm_private_dns_zone.speech_service_private_dns_zone.id
}