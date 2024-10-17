variable "management_group_id" {
  type    = string
  default = ""
}
variable "aks_oidc_issuer_url" {
  type    = string
  default = ""
}
variable "identities" {
  type = map(object({
    keyvault_id = string
    namespace   = string,
    roles       = list(string)
  }))
  default = {}
}