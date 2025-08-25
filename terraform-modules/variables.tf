variable "location_deployment" {
  type        = string
  description = "Location Parameter for Unique"
  default     = "switzerlandnorth"
}
variable "location_monitor" {
  type        = string
  description = "Location Parameter for Unique"
  default     = "switzerlandnorth"
}
variable "location_openai" {
  type        = string
  description = "Location Parameter for Unique"
  default     = "switzerlandnorth"
}
variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version to use."
  default     = "1.29.4"
}
variable "kubernetes_default_node_size" {
  type        = string
  description = "Kubernetes default node size."
  default     = "Standard_D8s_v5"
}
variable "gateway_global_config" {
  description = "Global configuration for the Application Gateway used to configure response and request buffering. Set to null to disable the global block."
  type = object({
    response_buffering_enabled = bool
    request_buffering_enabled  = bool
  })
  default = null
}
variable "openai_deployments" {
  description = "Map of deployment configurations"
  type = map(object({
    name          = string
    model_name    = string
    model_version = string
    sku_name      = string
    sku_capacity  = number
  }))
  default = {}
}
variable "openai_deployments_switzerlandnorth" {
  description = "Map of deployment configurations"
  type = map(object({
    name          = string
    model_name    = string
    model_version = string
    sku_name      = string
    sku_capacity  = number
  }))
  default = {}
}
variable "speech_service_private_dns_zone_virtual_network_link_name" {
  type        = string
  description = "Name of the private DNS zone virtual network link"
  default     = "speech-service-private-dns-zone-vnet-link-stageprojectname"
}
variable "speech_service_private_dns_zone_name" {
  type        = string
  description = "Name of the private DNS zone"
  default     = "privatelink.cognitiveservices.azure.com"
}
variable "speech_service_custom_subdomain_name" {
  type        = string
  description = "Custom subdomain name for the speech service"
  default     = "speech-service-stage-projectname-switzerlandnorth"
}
variable "application_name" {
  type        = string
  description = "Name of the application in camel case without hyphen or spaces."
  validation {
    condition     = (length(var.application_name) > 0)
    error_message = "Variable 'application_name' is missing."
  }
  validation {
    condition     = (length(var.application_name) <= 50)
    error_message = "Maximum length of 'application_name' is 50."
  }
}
variable "waf_mode" {
  type        = string
  description = "WAF mode which should be used. Can be Detection or Prevention."
  default     = "Prevention"
}
variable "flex_sku" {
  type        = string
  description = "SKU for the Azure FlexiblePostgreSQL server"
  default     = "GP_Standard_D2ds_v5"
}
variable "max_connections" {
  type        = string
  description = "Max connection count."
  default     = 200
}
variable "p0_email_addresses" {
  description = "List of email addresses for P0 alerts"
  type        = list(string)
  default     = []
}
variable "image_cleaner_interval_hours" {
  type        = number
  description = "Interval in hours for the image cleaner"
  default     = 48
}
variable "auto_scaler_scale_down_unneeded" {
  type        = string
  description = "Scale down unneeded nodes after this amount of time"
  default     = "5m"
}
variable "appgw_5xx_alert_threshold" {
  type        = number
  description = "Threshold for the appgw 5xx alert"
  default     = 8
}
variable "shutdown_schedule_enabled" {
  type        = bool
  description = "Enable the shutdown schedule"
  default     = true
}
variable "base_subnet" {
  type        = string
  description = "Base subnet for the virtual network"
  default     = "10.118.0.0/16"
}
variable "project_internal_name" {
  type        = string
  description = "Internal name of the project"
  default     = "client"
}
variable "company_identifier" {
  type        = string
  description = "Company identifier"
  default     = "moduleName"
}
variable "stage_alias" {
  type        = string
  description = "Stage alias"
  default     = "stage"
}
variable "base_domain" {
  type        = string
  description = "Base domain"
  default     = "stage-projectname.client.app"
}
variable "speech_service_public_network_access_enabled" {
  type        = bool
  description = "Enable public network access for the speech service. Can be disabled when using private endpoint."
  default     = true
}