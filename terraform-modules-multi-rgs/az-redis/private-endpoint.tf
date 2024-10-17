resource "azurerm_private_endpoint" "this" {
  name                = "${module.context.full_name}-redis"
  location            = module.context.rg_app_main.location
  resource_group_name = module.context.rg_app_main.name
  subnet_id           = var.subnet_redis.id
  tags                = module.context.tags
  private_service_connection {
    name                           = "${module.context.full_name}-redis-psc"
    private_connection_resource_id = azurerm_redis_cache.redis.id
    subresource_names              = ["redisCache"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = "${module.context.full_name}-redis-pdzg"
    private_dns_zone_ids = [azurerm_private_dns_zone.this.id]
  }
}
resource "azurerm_private_dns_zone" "this" {
  name                = "privatelink.redis.cache.windows.net"
  resource_group_name = module.context.rg_app_main.name
  tags                = module.context.tags
}
resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  name                  = module.context.full_name
  resource_group_name   = module.context.rg_app_main.name
  private_dns_zone_name = azurerm_private_dns_zone.this.name
  virtual_network_id    = var.virtual_network_id
  tags                  = module.context.tags
}
resource "azurerm_key_vault_secret" "redis-cache-fqdn" {
  name         = "redis-fqdn"
  value        = "${module.context.full_name}-redis.redis.cache.windows.net"
  key_vault_id = azurerm_key_vault.this.id
}