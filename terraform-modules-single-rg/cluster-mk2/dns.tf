resource "azurerm_dns_zone" "this" {
  name                = var.domain_config.name
  resource_group_name = module.context.resource_group.name
  tags                = module.context.tags
}
resource "azurerm_dns_a_record" "this" {
  name                = "@"
  zone_name           = azurerm_dns_zone.this.name
  resource_group_name = module.context.resource_group.name
  ttl                 = 300
  records             = [azurerm_public_ip.appgw.ip_address]
  tags                = module.context.tags
}
resource "azurerm_dns_a_record" "sub_domains" {
  for_each            = { for sub_domain in var.domain_config.sub_domains : sub_domain => sub_domain }
  name                = each.value
  zone_name           = azurerm_dns_zone.this.name
  resource_group_name = module.context.resource_group.name
  ttl                 = 300
  records             = [azurerm_public_ip.appgw.ip_address]
  tags                = module.context.tags
}
resource "azurerm_dns_caa_record" "caa" {
  name                = "@"
  zone_name           = azurerm_dns_zone.this.name
  resource_group_name = module.context.resource_group.name
  ttl                 = 300
  record {
    flags = 0
    tag   = "issue"
    value = "letsencrypt.org"
  }
  tags = module.context.tags
}