output "monitor_action_group_ids" {
  value = length(var.action_group_list) > 0 ? { for key, ag in azurerm_monitor_action_group.this : key => ag.id } : {}
}