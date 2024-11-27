variable "postgres_server_id" {
  type = string
}
variable "database_keyvault_id" {
  type    = string
  default = null
}
variable "openai_account_location" {
  type    = string
  default = "switzerlandnorth"
}
variable "storage_account_cors_rules" {
  description = "CORS rules for FGPT storage account."
  type = list(object({
    allowed_origins    = list(string)
    allowed_methods    = list(string)
    allowed_headers    = list(string)
    exposed_headers    = list(string)
    max_age_in_seconds = number
  }))
  default = []
}
variable "storage_account_change_feed_enabled" {
  type        = bool
  description = "Enable change feed for storage account. Must be enabled for point-in-time restore."
  default     = true
}
variable "storage_account_change_feed_retention_days" {
  type        = number
  description = "Number of days to retain change feed events. Must be bigger than restore_days."
  default     = 8
}
variable "storage_account_versioning_enabled" {
  type        = bool
  description = "Enable versioning for storage account. Must be enabled for point-in-time restore."
  default     = true
}
variable "storage_account_versioning_retention_days" {
  type        = number
  description = "Number of days to retain versions."
  default     = 8
}
variable "storage_account_container_delete_retention_days" {
  type        = number
  description = "Number of days to retain deleted containers."
  default     = 7
}
variable "storage_account_delete_retention_days" {
  type        = number
  description = "Number of days to retain deleted storage account."
  default     = 14
}
variable "storage_account_restore_days" {
  type        = number
  description = "Number of days blob can be restored. Must be used together with delete_retention_days, versioning_enabled and change_feed_enabled."
  default     = 7
}
variable "storage_account_backup_enabled" {
  type        = bool
  description = "Enable backup for storage account."
  default     = true
}
variable "storage_account_backup_redundancy" {
  type        = string
  description = "Redundancy for backup storage account."
  default     = "LocallyRedundant"
  validation {
    condition     = contains(["LocallyRedundant", "GeoRedundant", "ZoneRedundant"], var.storage_account_backup_redundancy)
    error_message = "must be one of LocallyRedundant, GeoRedundant, ZoneRedundant."
  }
}
variable "storage_account_backup_retention_days" {
  type        = number
  description = "Number of days to retain backups."
  default     = 14
}
variable "storage_account_backup_soft_delete" {
  type        = bool
  description = "Enable soft delete for backup storage account."
  default     = true
}
variable "storage_account_backup_retention_duration" {
  type        = string
  description = "Number of days to retain backups as duration string."
  default     = "P2W"
}
variable "min_tls_version" {
  default = "1.2"
}
variable "keyvault_access_principals" {
  type        = list(string)
  description = "Principals that can read the vault"
  default     = []
}
variable "azure_openai_endpoints" {
  type        = list(map(list(string)))
  description = "List of Azure OpenAI endpoints as lists per model-version that will be accessed using workload identity."
  default     = []
}
variable "azure_document_intelligence_endpoints" {
  type        = list(string)
  description = "List of FormRecognizer endpoints as list which will be accessed using workload identity."
  default     = []
}
variable "azure_document_intelligence_endpoint_definitions" {
  type = list(object({
    endpoint = string
    location = string
  }))
  description = "List of FormRecognizer endpoint definitions as list which will be accessed using workload identity."
  default     = []
}
variable "user_assigned_identity_ids" {
  type    = list(string)
  default = []
}
variable "ingestion_encryption_key_version" {
  description = "Increment to rotate the encryption key. If rotated, currently valid links might become invalid but can be requested again with the new key."
  default     = "1"
}
variable "chat_lxm_encryption_key_version" {
  description = "Increment to rotate the encryption key. If rotated, currently valid lxm api keys become invalid and need to be updated again."
  default     = "1"
}
variable "gpt_35_turbo_tpm_thousands" {
  type    = number
  default = 240
}
variable "gpt_35_turbo_16k_tpm_thousands" {
  type    = number
  default = 240
}
variable "gpt_4_0613_tpm_thousands" {
  type    = number
  default = 40
}
variable "gpt_4_32k_0613_tpm_thousands" {
  type    = number
  default = 80
}
variable "text_embedding_ada_002_tpm_thousands" {
  type    = number
  default = 350
}
variable "aks_oidc_issuer_url" {
  description = "The AKS OIDC issuer URL where the chat gets deployed to."
  type        = string
}
variable "sdk_deployment_service_principal_object_ids" {
  description = "Principals that can read the storage account keys in order to wire an Azure Container App (or similar) to a Storage Account via a Diagnostic Setting."
  type        = list(string)
  default     = []
}
variable "storage_account_key_list_operator_service_role_id" {
  description = "The role UUID for the role that allows listing keys in a storage account. For Unique these roles are provisioned at Tenant Root Level + 1 Management Group."
  type        = string
  default     = "08cd0797-6e0a-87fd-2800-a7b09ecea35c"
}
variable "sdk_deployment_logs_destination_azure_subscription_id" {
  description = "The UUID of the subscription where the logs will be stored. It is used by the App Repository to look for the logs in the right place."
  type        = string
  default     = ""
}
variable "sdk_deployment_logs_destination_azure_resource_group_name" {
  description = "The name of the resource group where the logs will be stored. It is used by the App Repository to look for the logs in the right place."
  type        = string
  default     = ""
}
variable "bing_search_v7_sku_name" {
  description = "The SKU to use for the Bing Web Search resources."
  default     = "S2"
  type        = string
}
variable "log_analytics_workspace_id" {
  type    = string
  default = ""
}