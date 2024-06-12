variable "storage_account_min_tls_version" {
  default = "1.2"
}
variable "storage_account_customer_managed_key_size" {
  description = "Key size for debug logs. NIST still recommends 2048."
  default     = 2048
}
variable "storage_account_retention_period_days" {
  type    = number
  default = 7
  validation {
    condition     = var.storage_account_retention_period_days > 0 && var.storage_account_retention_period_days <= 31
    error_message = "The 'storage_account_retention_period_days' variable must be between 1 and 31 days."
  }
}
variable "keyvault_access_principals" {
  type        = list(string)
  description = "Principals that can read the vault to get the storage account URI."
  default     = []
}
variable "workload_identity" {
  type = object({
    aks_oidc_issuer_url = string
    namespace           = optional(string, "apps")
    service_name        = optional(string, "node-app-repository")
  })
}
variable "sdk_deployment_service_principal_object_ids" {
  description = "Principals that can read the storage account keys in order to wire an Azure Container App (or similar) to a Storage Account via a Diagnostic Setting."
  type        = list(string)
  default     = []
}
variable "storage_account_key_list_operator_service_role_id" {
  description = "The role UUID for the role that allows listing keys in a storage account. For Unique these roles are provisioned at Tenant Root Level + 1 Management Group."
  type        = string
}
variable "logs_destination_azure_subscription_id" {
  description = "The UUID of the subscription where the logs will be stored. It is used by the App Repository to look for the logs in the right place."
  type        = string
  default     = ""
}
variable "logs_destination_azure_resource_group_name" {
  description = "The name of the resource group where the logs will be stored. It is used by the App Repository to look for the logs in the right place."
  type        = string
  default     = ""
}