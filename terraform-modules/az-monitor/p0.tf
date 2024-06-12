resource "azurerm_monitor_action_group" "p0" {
  name                = "p0-${module.context.full_name}"
  resource_group_name = module.context.resource_group.name
  short_name          = "p0${module.context.project}"
  dynamic "email_receiver" {
    for_each = var.p0_email_addresses
    content {
      name                    = "e-${module.context.project}-${email_receiver.key}"
      email_address           = email_receiver.value.email_address
      use_common_alert_schema = true
    }
  }
  tags = module.context.tags
}