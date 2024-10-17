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
variable "user_assigned_identity_ids" {
  type    = list(string)
  default = []
}