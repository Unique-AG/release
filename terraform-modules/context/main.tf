resource "random_string" "postfix" {
  length  = local.random_postfix_length
  special = false
  upper   = false
  keepers = {
    name = local.full_name
  }
}
data "azurerm_client_config" "current" {}