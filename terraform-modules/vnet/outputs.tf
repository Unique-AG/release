output "subnets" {
  value = { for i, subnet in var.subnets : subnet.name => {
    id       = azurerm_subnet.this[subnet.name].id
    name     = subnet.name
    size     = subnet.size
    cidr     = azurerm_subnet.this[subnet.name].address_prefixes[0]
    resource = azurerm_subnet.this[subnet.name]
  } if subnet.name != null }
}
output "virtual_network_id" {
  value = azurerm_virtual_network.this.id
}