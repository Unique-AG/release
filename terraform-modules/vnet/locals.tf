locals {
  base_subnet_size = parseint(split("/", var.base_subnet)[1], 10)
  cirds = cidrsubnets(var.base_subnet, [for subnet in var.subnets : subnet.size - local.base_subnet_size]...)
  actual_subnets = [for subnet in var.subnets : subnet if subnet.name != null]
  actual_cirds   = [for i, subnet in var.subnets : local.cirds[i] if subnet.name != null]
}