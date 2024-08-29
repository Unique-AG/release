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
    "manual-github-monorepo-url",
    "manual-github-gitops-resources-url",
    "manual-github-app-id",
    "manual-github-installation-id",
    "manual-uniqueapp-docker-config-json",
    "manual-chart-pull-username",
    "manual-chart-pull-password"
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
  }
}
variable "rabbitmq-port" {
  type    = number
  default = 5672
}