# VNET Terraform module - craete a Azure Virtual Network and subnets

This module creates a Azure Virtual Network and calculates a sequence of consecutive IP address ranges within a particular CIDR prefix. Additionally it can create subnets and delegations and virtual network peerings.

## Module Inputs

- `resource_group_name`: The name of the resource group to create the VNET in.
- `full_name`: The full name prefix of the resources.
- `namespace`: The namespace tag of the resources.
- `location`: The location/region where the VNET is created.
- `project`: The project tag of the resources.
- `environment`: The environment tag of the resources.
- `base_subnet`: The base subnet CIDR block to create the subnets in, e.g., 10.0.0.0/16.
- `subnets`: A list of subnets to create.
- `virtual_network_peerings`: (Optional) A list of virtual network peerings to create.

## Module Structure

### Resource Creation

1. **VNET:**
   - An Azure VNET is created using the `azurerm_virtual_network` resource.

2. **Virtual Network Peerings:**
   - Optional virtual network peerings are created using the `azurerm_virtual_network_peering` resource.

3. **Subnets:**
   - Subnets are created using the `azurerm_subnet` resource.

### Dynamic Blocks

- The `subnets` and `virtual_network_peerings` arguments use dynamic blocks to iterate over the provided configurations.
- The `delegation` block within the `azurerm_subnet` resource is also dynamic, allowing for multiple delegations per subnet.

### Variable Usage

- The code utilizes variables like `var.base_subnet` and `local.actual_cidrs` to dynamically calculate subnet CIDR blocks.
- It also references variables like `module.context.full_name` and `module.context.resource_group.name` to access information from the module context.

## Notes

- If you create a small before a bigger subnet, the might be a bigger space of unused IPs between those subnets. This is not a problem, but it is not efficient. If you want to be efficient, create the bigger subnets first.
- If you add new subnets between existing onces, the subnets afterwards may change. This may trigger mayor changes in your infrastructure. If you want to avoid this, only append new subnets at the end of the list.
- If you don't need a subnet anymore and want to delete it, don't delete it and change the name to `null`. This will remove the unused subnet but keep the existing subnets structure instanct. You may can reuse it later again.

## Example Usage

```hcl
module "vnet" {
  source              = "../../modules/vnet"
  resource_group_name = local.resource_group_name
  namespace           = local.namespace
  full_name           = local.full_name
  location            = local.location
  project             = local.project
  environment         = local.environment

  base_subnet = "10.10.0.0/16"

  subnets = [
    {  # Would create 10.10.0.0/28
      name = "AppGW"
      size = 28
    },
    {  # Would create 10.10.0.16/28
      name = "AksTykRedis",
      size = 28
    },
    {  # Would create 10.10.1.0/24
      name = "AksNodes"
      size = 24
    },
    {  # Would create 10.10.2.0/24
      name = "FlexiblePostgres"
      size = 24
      delegations = [
        {
          name = "fs"
          service_delegations = [{
            name = "Microsoft.DBforPostgreSQL/flexibleServers"
            actions = [
              "Microsoft.Network/virtualNetworks/subnets/join/action",
            ]
          }]
        }
      ]
      service_endpoints = ["Microsoft.Storage"]
    },
    {  # Would create 10.10.16.0/20
      name = "AksPods"
      size = 20
      delegations = [
        {
          name = "aks-delegation"
          service_delegations = [{
            actions = [
              "Microsoft.Network/virtualNetworks/subnets/join/action",
            ]
            name = "Microsoft.ContainerService/managedClusters"
          }]
        }
      ]
    },
  ]
}
```

## Argument Reference

The following arguments are supported:

- `resource_group_name` - (Required) The resource group name to create the virtual network in.
- `full_name` - (Required) The full name prefix of the resources.
- `namespace` - (Required) The namespace tag of the resources.
- `location` - (Required) The location/region where the virtual network is created.
- `project` - (Required) The project tag of the resources.
- `environment` - (Required) The environment tag of the resources.
- `base_subnet` - (Required) The base subnet CIDR block to create the subnets in, eg. 10.0.0.0/16.
- `subnets` - (Required) A list of subnets to create. See `subnets` below for details.
- `virtual_network_peerings` - (Optional) A list of virtual network peerings to create.. See `virtual_network_peerings` below for details.

---

`subnets` supports the following:

- `name` - (Required) The name of the subnet.
- `size` - (Required) The size of the subnet by subnet mask bits, eg. 24.
- `delegations` - (Optional) A list of delegations to create. See `delegations` below for details.
- `service_endpoints` - (Optional) A list of service endpoints to create.

---

`delegations` supports the following:

- `name` - (Required) The name of the delegation.
- `service_delegations` - (Required) A list of service delegations to create. See `service_delegations` below for details.

---

`service_delegations` supports the following:

- `name` - (Required) The name of the service delegation.
- `actions` - (Required) A list of actions to create.

---

`virtual_network_peerings` supports the following:

- `name` - (Required) The name of the virtual network peering.
- `id` - (Required) The ID of the remote virtual network.
