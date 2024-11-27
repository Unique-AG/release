module "app-repository-logs" {
  source  = "../app-repository-logs"
  context = module.context
  workload_identity = {
    aks_oidc_issuer_url = var.aks_oidc_issuer_url
  }
  logs_destination_azure_subscription_id            = var.sdk_deployment_logs_destination_azure_subscription_id
  logs_destination_azure_resource_group_name        = var.sdk_deployment_logs_destination_azure_resource_group_name
  keyvault_access_principals                        = var.keyvault_access_principals
  storage_account_key_list_operator_service_role_id = var.storage_account_key_list_operator_service_role_id
  sdk_deployment_service_principal_object_ids       = var.sdk_deployment_service_principal_object_ids
  log_analytics_workspace_id                        = var.log_analytics_workspace_id
}