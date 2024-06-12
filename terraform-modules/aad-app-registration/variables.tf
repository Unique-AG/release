variable "keyvault_id" {
  type        = string
  description = "Keyvault where to store the app credentials"
}
variable "redirect_uris" {
  description = "Authorized redirects"
  default     = []
}
variable "redirect_uris_public_native" {
  description = "Public client/native (mobile & desktop) redirects"
  default     = []
}
variable "use_intune" {
  description = "If single-tenant uses intune, adds required scope"
  default     = false
}
variable "owner_user_object_ids" {
  type    = list(string)
  default = []
}