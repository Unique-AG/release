variable "base_subnet" {
  type        = string
  description = "The base subnet CIDR block to create the subnets in, eg. 10.0.0.0/16."
  validation {
    condition     = can(cidrhost(var.base_subnet, 32))
    error_message = "Must be valid IPv4 CIDR."
  }
}
variable "subnets" {
  type = list(object({
    name = string
    size = number
    delegations = optional(list(object({
      name = string
      service_delegations = list(object({
        name    = string
        actions = list(string)
      }))
    })), [])
    service_endpoints                 = optional(list(string), [])
    private_endpoint_network_policies = optional(string, "Enabled")
  }))
  description = "List of subnets to create"
}
variable "virtual_network_peerings" {
  type = list(object({
    name = string
    id   = string
  }))
  description = "List of virtual network peerings to create."
  default     = []
}