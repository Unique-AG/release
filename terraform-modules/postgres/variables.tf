variable "delegated_subnet_id" {
  type = string
}
variable "virtual_network_id" {
  type = string
}
variable "keyvault_access_principals" {
  type        = list(string)
  description = "Principals that can read the vault"
  default     = []
}
variable "flex_sku" {
  type        = string
  description = "SKU for the Azure FlexiblePostgreSQL server"
  default     = "GP_Standard_D2ds_v5"
}
variable "flex_storage_mb" {
  type        = number
  description = "Storage from the Azure FlexiblePostgreSQL server in MB"
  default     = 32768
}
variable "flex_pg_version" {
  type        = string
  description = "Postgres version the Azure FlexiblePostgreSQL server "
  default     = "14"
}
variable "parameters" {
  type        = map(string)
  description = "Additional parameters to pass to the Azure FlexiblePostgreSQL server - https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-server-parameters"
  default     = {}
}
variable "log_analytics_workspace_id" {
  type        = string
  description = "ID of the Log Analytics workspace"
  default     = null
}