locals {
  full_name_max_length  = 24
  random_postfix_length = 6
  name                  = var.name == null ? var.context.name : var.name
  namespace             = var.namespace == null ? var.context.namespace : var.namespace
  project               = var.project == null ? var.context.project : var.project
  environment           = var.environment == null ? var.context.environment : var.environment
  tags                  = merge(var.context.tags, var.tags)
  rg_app_main           = var.rg_app_main == null ? var.context.rg_app_main : var.rg_app_main
  rg_app_net            = var.rg_app_net == null ? var.context.rg_app_net : var.rg_app_net
  rg_app_tf             = var.rg_app_tf == null ? var.context.rg_app_tf : var.rg_app_tf
  rg_app_sec            = var.rg_app_sec == null ? var.context.rg_app_sec : var.rg_app_sec
  rg_app_audit          = var.rg_app_audit == null ? var.context.rg_app_audit : var.rg_app_audit
  base_name             = local.project == null ? "${local.namespace}-${local.environment}" : "${local.namespace}-${local.project}-${local.environment}"
  full_name             = local.name == null ? local.base_name : "${local.base_name}-${local.name}"
  full_name_no_dashes   = replace(local.full_name, "-", "")
}