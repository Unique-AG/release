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
    "manual-github-app-private-key",
    "manual-google-search-api-key",
    "manual-six-api-creds",
    "manual-confluence-connector-service-user-client-id",
    "manual-confluence-connector-service-user-client-secret",
    "manual-confluence-connector-username",
    "manual-confluence-connector-password",
    "manual-confluence-connector-pat"
  ]
}
variable "rabbitmq-port" {
  type    = number
  default = 5672
}
variable "sentinel_log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics Workspace used by Sentinel for audit log forwarding"
  type        = string
  default     = "/subscriptions/926bb92d-ce73-43e5-97eb-9965e0f0b238/resourceGroups/rg-infra-security-sentinel/providers/Microsoft.OperationalInsights/workspaces/law-infra-security-sentinel"
}