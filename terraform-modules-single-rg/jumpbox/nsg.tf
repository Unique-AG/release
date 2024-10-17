resource "azurerm_network_security_group" "nsg" {
  name                = module.context.full_name
  location            = module.context.resource_group.location
  resource_group_name = module.context.resource_group.name
  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "ssh"
    priority                   = 200
    protocol                   = "Tcp"
    destination_address_prefix = "${module.virtual-machine.network_interface_private_ip}/32"
    destination_port_range     = "22"
    source_address_prefix      = var.bastion_subnet.cidr
    source_port_range          = "*"
  }
}
resource "azurerm_subnet_network_security_group_association" "nsg" {
  subnet_id                 = var.jumpbox_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}