variable "keyvault_access_principals" {
  type        = list(string)
  description = "Principals that can read the automation vault"
  default     = []
}
variable "keyvault_secret_placeholders" {
  description = "List of empty secret placeholders to be created for manually setting the value later"
  default = [
    "manual-ld-sdk-key",
    "manual-zitadel-scope-mgmt-pat",
    "manual-acr-image-pull-username",
    "manual-acr-image-pull-password",
    "manual-app-repository-encryption-key",
    "manual-slack-webhook-url",
  ]
}