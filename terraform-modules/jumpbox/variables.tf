variable "jumpbox_size" {
  type    = string
  default = "Standard_B2s"
}
variable "jumpbox_subnet" {
  type = object({
    id       = string
    name     = string
    cidr     = string
    size     = number
    resource = optional(any, null)
  })
}
variable "bastion_subnet" {
  type = object({
    id       = string
    name     = string
    cidr     = string
    size     = number
    resource = optional(any, null)
  })
}
variable "log_analytics_workspace_id" {
  type = string
}
variable "cloud_init_scripts_version" {
  type    = string
  default = ""
}