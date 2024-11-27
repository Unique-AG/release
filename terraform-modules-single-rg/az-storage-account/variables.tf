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
variable "log_analytics_workspace_id" {
  type    = string
  default = ""
}