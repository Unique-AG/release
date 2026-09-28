resource "azurerm_network_security_group" "nodes" {
  name                = "${module.context.full_name}-nodes"
  location            = module.context.rg_app_main.location
  resource_group_name = module.context.rg_app_main.name
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
  dynamic "security_rule" {
    for_each = local.cilium_node_rules
    content {
      name                       = security_rule.key
      priority                   = security_rule.value.priority
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = security_rule.value.protocol
      source_port_range          = "*"
      destination_port_range     = security_rule.value.port
      source_address_prefixes    = [var.subnet_nodes.cidr, var.subnet_pods.cidr]
      destination_address_prefix = "*"
    }
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
locals {
  cilium_node_rules = var.cilium_enabled ? {
    "Cilium-Hubble-Server"  = { priority = 110, protocol = "Tcp", port = "4244" }
    "Cilium-Health"         = { priority = 111, protocol = "Tcp", port = "4240" }
    "Cilium-Health-ICMP"    = { priority = 112, protocol = "Icmp", port = "*" }
    "Cilium-Agent-Metrics"  = { priority = 113, protocol = "Tcp", port = "9962" }
    "Cilium-Hubble-Metrics" = { priority = 114, protocol = "Tcp", port = "9965" }
  } : {}
  cilium_pod_rules = var.cilium_enabled ? {
    "Cilium-Health-From-Nodes"        = { priority = 110, protocol = "Tcp", port = "4240" }
    "Cilium-Health-ICMP-From-Nodes"   = { priority = 111, protocol = "Icmp", port = "*" }
    "Cilium-DNS-Proxy-UDP-From-Nodes" = { priority = 112, protocol = "Udp", port = "53" }
    "Cilium-DNS-Proxy-TCP-From-Nodes" = { priority = 113, protocol = "Tcp", port = "53" }
  } : {}
}
resource "azurerm_subnet_network_security_group_association" "nodes" {
  subnet_id                 = var.subnet_nodes.id
  network_security_group_id = azurerm_network_security_group.nodes.id
}
resource "azurerm_network_security_group" "pods" {
  name                = "${module.context.full_name}-pods"
  location            = module.context.rg_app_main.location
  resource_group_name = module.context.rg_app_main.name
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
  dynamic "security_rule" {
    for_each = local.cilium_pod_rules
    content {
      name                       = security_rule.key
      priority                   = security_rule.value.priority
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = security_rule.value.protocol
      source_port_range          = "*"
      destination_port_range     = security_rule.value.port
      source_address_prefix      = var.subnet_nodes.cidr
      destination_address_prefix = "*"
    }
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