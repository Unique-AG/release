locals {
  full_name_max_length  = 24
  random_postfix_length = 6
  name                  = var.name == null ? var.context.name : var.name
  namespace             = var.namespace == null ? var.context.namespace : var.namespace
  project               = var.project == null ? var.context.project : var.project
  environment           = var.environment == null ? var.context.environment : var.environment
  tags                  = merge(var.context.tags, var.tags)
  resource_group        = var.resource_group == null ? var.context.resource_group : var.resource_group
  base_name             = local.project == null ? "${local.namespace}-${local.environment}" : "${local.namespace}-${local.project}-${local.environment}"
  full_name             = local.name == null ? local.base_name : "${local.base_name}-${local.name}"
  full_name_no_dashes   = replace(local.full_name, "-", "")
}