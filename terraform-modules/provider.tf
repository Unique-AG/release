provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}
variable "resource_group_name" {}
variable "storage_account_name" {}
variable "container_name" {}
variable "subscription_id" {}
variable "tenant_id" {}
variable "key" {}