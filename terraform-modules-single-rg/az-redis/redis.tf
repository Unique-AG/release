resource "azurerm_redis_cache" "redis" {
  name                          = "${module.context.full_name}-redis"
  location                      = module.context.resource_group.location
  resource_group_name           = module.context.resource_group.name
  capacity                      = 1
  family                        = "C"
  sku_name                      = "Standard"
  minimum_tls_version           = "1.2"
  public_network_access_enabled = false
  redis_version                 = 6
  tags                          = local.tags
}
resource "azurerm_network_security_group" "redis" {
  name                = "${module.context.full_name}-redis"
  location            = module.context.resource_group.location
  resource_group_name = module.context.resource_group.name
  security_rule {
    name                       = "AllowToRedis"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6379-6380"
    source_address_prefix      = var.subnet_pods.cidr
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "DenyAll"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = local.tags
}
resource "azurerm_subnet_network_security_group_association" "nsg" {
  subnet_id                 = var.subnet_redis.id
  network_security_group_id = azurerm_network_security_group.redis.id
}
resource "azurerm_key_vault_secret" "redis-cache-password" {
  name         = "redis-password"
  value        = azurerm_redis_cache.redis.primary_access_key
  key_vault_id = azurerm_key_vault.this.id
}
resource "azurerm_key_vault_secret" "redis-cache-host-dns" {
  name         = "redis-host"
  value        = azurerm_redis_cache.redis.hostname
  key_vault_id = azurerm_key_vault.this.id
}
resource "azurerm_key_vault_secret" "redis-cache-port" {
  name         = "redis-port"
  value        = azurerm_redis_cache.redis.ssl_port
  key_vault_id = azurerm_key_vault.this.id
}