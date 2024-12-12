module "openai" {
  source                     = "../az-openai"
  name                       = "openai"
  context                    = module.context
  account_location           = var.openai_account_location
  key_vault_id               = azurerm_key_vault.document-chat.id
  deployments                = var.openai_deployments
  user_assigned_identity_ids = var.user_assigned_identity_ids
}