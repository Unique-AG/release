variable "api_version" {
  type        = string
  description = "API version to use."
  default     = "2023-05-01"
}
variable "account_name" {
  type    = string
  default = ""
}
variable "account_location" {
  type = string
}
variable "custom_subdomain_name" {
  type    = string
  default = ""
}
variable "deployments" {
  type = map(object({
    name            = string
    model_name      = string
    model_version   = string
    sku_name        = string
    sku_capacity    = number
    rai_policy_name = optional(string, "Default")
    chat            = optional(bool, true)
  }))
  default  = {}
  nullable = false
}
variable "key_vault_id" {
  description = "If a value is passed, the module will use the key vault to store the secrets."
  type        = string
  default     = ""
}
variable "key_vault_prefix" {
  description = "If a value is passed, the module will use this prefix to store vault values as (*-key, *-endpoint). This value overrides the module.context.name which would be used as default prefix."
  type        = string
  default     = ""
}
variable "user_assigned_identity_ids" {
  type    = list(string)
  default = []
}
variable "log_analytics_workspace_id" {
  type    = string
  default = ""
}