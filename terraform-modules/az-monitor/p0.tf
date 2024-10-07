resource "azurerm_monitor_action_group" "this" {
  for_each            = length(var.action_group_list) > 0 ? var.action_group_list : {}
  name                = "${each.value.severity}-${module.context.full_name}-${each.key}"
  resource_group_name = module.context.resource_group.name
  short_name          = lower(substr("${each.value.severity}-${substr(each.key, 0, 8)}", 0, 12))
  dynamic "email_receiver" {
    for_each = toset(each.value.email_addresses)
    content {
      name                    = "e-${module.context.project}-${split("@", email_receiver.value)[0]}"
      email_address           = email_receiver.value
      use_common_alert_schema = true
    }
  }
  tags = module.context.tags
}