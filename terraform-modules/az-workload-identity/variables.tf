variable "aks_oidc_issuer_url" {
  type    = string
  default = ""
}
variable "identities" {
  description = "A map of workload identities to create where each key specifies includes the keyvault_id, namespace, and Azure RM roles."
  type = map(object({
    keyvault_id = string
    namespace   = string,
    roles       = list(string)
  }))
  default = {}
}