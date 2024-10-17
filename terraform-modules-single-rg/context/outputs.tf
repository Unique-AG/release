output "name" {
  value = local.name
}
output "full_name" {
  value = local.full_name
}
output "full_name_no_dashes" {
  value = local.full_name_no_dashes
}
output "full_name_truncated" {
  value = length(local.full_name) > local.full_name_max_length ? "${substr(local.full_name, 0, local.full_name_max_length - local.random_postfix_length - 2)}-${random_string.postfix.result}" : local.full_name
}
output "full_name_no_dashes_truncated" {
  value = length(local.full_name_no_dashes) > local.full_name_max_length ? "${substr(local.full_name_no_dashes, 0, local.full_name_max_length - local.random_postfix_length - 1)}${random_string.postfix.result}" : local.full_name_no_dashes
}
output "namespace" {
  value = local.namespace
}
output "project" {
  value = local.project
}
output "environment" {
  value = local.environment
}
output "tags" {
  value = local.tags
}
output "resource_group" {
  value = local.resource_group
}
output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}
output "subscription_id" {
  value = data.azurerm_client_config.current.subscription_id
}
output "random_postfix" {
  description = "Each context has a unique, random postfix to avoid naming conflicts."
  value       = random_string.postfix.result
}