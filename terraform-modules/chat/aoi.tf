module "openai" {
  source           = "../az-openai"
  name             = "openai"
  context          = module.context
  account_location = var.openai_account_location
  key_vault_id     = azurerm_key_vault.document-chat.id
  deployments = {
    "gpt-35-turbo-16k" = {
      name          = "gpt-35-turbo-16k"
      model_name    = "gpt-35-turbo-16k"
      model_version = "0613"
      sku_name      = "Standard"
      sku_capacity  = var.gpt_35_turbo_16k_tpm_thousands
    }
    "gpt-35-turbo" = {
      name          = "gpt-35-turbo"
      model_name    = "gpt-35-turbo"
      model_version = "0613"
      sku_name      = "Standard"
      sku_capacity  = var.gpt_35_turbo_tpm_thousands
    }
    "text-embedding-ada-002" = {
      name          = "text-embedding-ada-002"
      model_name    = "text-embedding-ada-002"
      model_version = "2"
      sku_name      = "Standard"
      sku_capacity  = 240
    }
    "gpt-4" = {
      name          = "gpt-4"
      model_name    = "gpt-4"
      model_version = "0613"
      sku_name      = "Standard"
      sku_capacity  = var.openai_account_location == "francecentral" ? 20 : 40
    }
    "gpt-4-32k" = {
      name          = "gpt-4-32k"
      model_name    = "gpt-4-32k"
      model_version = "0613"
      sku_name      = "Standard"
      sku_capacity  = var.openai_account_location == "francecentral" ? 60 : 80
    }
  }
  user_assigned_identity_ids = var.user_assigned_identity_ids
}