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
      sku_capacity  = (var.openai_account_location == "francecentral" || var.openai_account_location == "westeurope") ? 240 : var.text_embedding_ada_002_tpm_thousands
      chat          = false
    }
    "gpt-4" = {
      name          = "gpt-4"
      model_name    = "gpt-4"
      model_version = "0613"
      sku_name      = "Standard"
      sku_capacity  = var.openai_account_location == "francecentral" ? 20 : var.gpt_4_0613_tpm_thousands
    }
    "gpt-4-32k" = {
      name          = "gpt-4-32k"
      model_name    = "gpt-4-32k"
      model_version = "0613"
      sku_name      = "Standard"
      sku_capacity  = var.openai_account_location == "francecentral" ? 60 : var.gpt_4_32k_0613_tpm_thousands
    }
  }
  user_assigned_identity_ids = var.user_assigned_identity_ids
  log_analytics_workspace_id = var.log_analytics_workspace_id
}