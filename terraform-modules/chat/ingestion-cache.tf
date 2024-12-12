module "ingestion-cache" {
  source                     = "../az-storage-account"
  name                       = "ingestion-cache"
  context                    = module.context
  keyvault_access_principals = var.keyvault_access_principals
  storage_account_cors_rules = var.storage_account_cors_rules
  retention_period_days      = 1
}