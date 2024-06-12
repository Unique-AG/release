output "monitor_action_group_ids" {
  value = {
    p0 = azurerm_monitor_action_group.p0.id
  }
}