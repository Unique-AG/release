variable "postgres_server_id" {
  type = string
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