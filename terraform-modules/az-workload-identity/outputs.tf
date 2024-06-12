output "user_assigned_identity_ids" {
  value = {
    for k, o in azurerm_user_assigned_identity.this : k => o.id
  }
}