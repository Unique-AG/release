resource "azurerm_virtual_network" "this" {
  name                = module.context.full_name
  location            = module.context.rg_app_net.location
  resource_group_name = module.context.rg_app_net.name
  address_space       = [var.base_subnet]
  tags                = module.context.tags
}
resource "azurerm_virtual_network_peering" "shared" {
  for_each                     = { for peering in var.virtual_network_peerings : peering.name => peering }
  name                         = "${module.context.full_name}-${each.value.name}"
  resource_group_name          = module.context.rg_app_net.name
  virtual_network_name         = azurerm_virtual_network.this.name
  remote_virtual_network_id    = each.value.id
  allow_virtual_network_access = false
  allow_forwarded_traffic      = false
  use_remote_gateways          = false
}
resource "azurerm_subnet" "this" {
  for_each                          = { for i, subnet in local.actual_subnets : subnet.name => merge(subnet, { index = i }) }
  name                              = each.value.name
  resource_group_name               = module.context.rg_app_net.name
  virtual_network_name              = azurerm_virtual_network.this.name
  address_prefixes                  = [local.actual_cirds[each.value.index]]
  private_endpoint_network_policies = each.value.private_endpoint_network_policies
  service_endpoints                 = each.value.service_endpoints
  dynamic "delegation" {
    for_each = each.value.delegations
    content {
      name = "aks-delegation"
      dynamic "service_delegation" {
        for_each = delegation.value.service_delegations
        content {
          actions = service_delegation.value.actions
          name    = service_delegation.value.name
        }
      }
    }
  }
}