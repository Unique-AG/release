resource "azurerm_network_security_group" "nodes" {
  name                = "${module.context.full_name}-nodes"
  location            = module.context.resource_group.location
  resource_group_name = module.context.resource_group.name
  security_rule {
    name                       = "DNS-UDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "53"
    source_address_prefix      = "10.0.0.0/8"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "DNS-TCP"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "53"
    source_address_prefix      = "10.0.0.0/8"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "SSH"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.0.0/8"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "HTTPS"
    priority                   = 103
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.0.0.0/8"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "KubeLogs"
    priority                   = 104
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "10250"
    source_address_prefix      = "10.0.0.0/8"
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
  tags = module.context.tags
}
resource "azurerm_subnet_network_security_group_association" "nodes" {
  subnet_id                 = var.subnet_nodes.id
  network_security_group_id = azurerm_network_security_group.nodes.id
}
resource "azurerm_network_security_group" "pods" {
  name                = "${module.context.full_name}-pods"
  location            = module.context.resource_group.location
  resource_group_name = module.context.resource_group.name
  security_rule {
    name                       = "Allow-Inter-Pod-Communication"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.subnet_pods.cidr
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Allow-AppGW-Communication"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.subnet_appgw.cidr
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
  tags = module.context.tags
}
resource "azurerm_subnet_network_security_group_association" "pods" {
  subnet_id                 = var.subnet_pods.id
  network_security_group_id = azurerm_network_security_group.pods.id
}