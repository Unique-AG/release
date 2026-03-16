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
variable "customer_managed_key_size" {
  default = 4096
}
variable "retention_period_days" {
  type    = number
  default = -1
}
variable "keyvault_access_principals" {
  type        = list(string)
  description = "Principals that can read the vault"
  default     = []
}
variable "sentinel_log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics Workspace used by Sentinel for audit log forwarding"
  type        = string
  default     = "/subscriptions/926bb92d-ce73-43e5-97eb-9965e0f0b238/resourceGroups/rg-infra-security-sentinel/providers/Microsoft.OperationalInsights/workspaces/law-infra-security-sentinel"
}