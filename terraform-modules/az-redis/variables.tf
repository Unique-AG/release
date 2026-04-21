variable "subnet_pods" {
  type = object({
    id       = string
    name     = string
    cidr     = string
    size     = number
    resource = optional(any, null)
  })
  description = "Subnet object where the Kubernetes pods should be living."
}
variable "subnet_redis" {
  type = object({
    id   = string
    name = string
    cidr = string
  })
  description = "Subnet object where redis should be living."
}
variable "keyvault_access_principals" {
  type        = list(string)
  description = "Principals that can read the vault"
  default     = []
}
variable "virtual_network_id" {
  type = string
}
variable "monitor_action_group_ids" {
  type = object({
    p0 = optional(string)
    p1 = optional(string)
    p2 = optional(string)
    p3 = optional(string)
    p4 = optional(string)
  })
  description = "Action group ids for responders grouped by alert priority."
  default     = {}
}