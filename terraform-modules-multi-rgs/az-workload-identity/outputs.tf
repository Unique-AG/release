output "user_assigned_identity_ids" {
  value = {
    for k, o in azurerm_user_assigned_identity.this : k => o.id
  }
}
output "user_assigned_identity_client_ids" {
  value = {
    for k, o in azurerm_user_assigned_identity.this : k => o.client_id
  }
}