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
    "manual-uniqueapp-docker-config-json",
    "manual-chart-pull-password",
    "manual-confluence-connector-service-user-client-id",
    "manual-confluence-connector-service-user-client-secret",
    "manual-confluence-connector-username",
    "manual-confluence-connector-password",
    "manual-confluence-connector-pat"
  ]
}
variable "argocd-secrets-list" {
  description = "Map of secret names and their values for ArgoCD"
  type        = map(string)
  default = {
    uniqueapp-acr-url                = "uniqueapp.azurecr.io"
    uniquecr-acr-url                 = "uniquecr.azurecr.io"
    helm-registry-name               = "uniquecr"
    argocd-registry-type             = "helm"
    helm-registry-enableoci          = "true"
    helm-registry-forcehttpbasicauth = "true"
    github-monorepo-url              = "https://github.com/Unique-AG/monorepo"
    github-gitops-resources-url      = "https://github.com/Unique-AG/gitops-resources"
    github-app-id                    = "961557"
    github-installation-id           = "53486715"
    chart-pull-username              = "ext-unique-gitops-resources"
  }
}
variable "rabbitmq-port" {
  type    = number
  default = 5672
}
variable "log_analytics_workspace_id" {
  type    = string
  default = ""
}