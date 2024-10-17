locals {
  workload_roles = distinct(flatten([
    for key, identity in var.identities : [
      for role in identity.roles : {
        service              = key
        role_definition_name = role
      }
    ]
  ]))
}
resource "azurerm_user_assigned_identity" "this" {
  for_each            = var.identities
  name                = "${module.context.full_name}-wid-${each.key}"
  location            = module.context.resource_group.location
  resource_group_name = module.context.resource_group.name
}
resource "azurerm_role_assignment" "this" {
  for_each             = { for entry in local.workload_roles : "${entry.role_definition_name}.${entry.service}" => entry }
  scope                = data.azurerm_management_group.this.id
  role_definition_name = each.value.role_definition_name
  principal_id         = azurerm_user_assigned_identity.this[each.value.service].principal_id
}
resource "azurerm_federated_identity_credential" "this" {
  for_each            = var.identities
  name                = "${module.context.full_name}-federated-wid-${each.key}"
  resource_group_name = module.context.resource_group.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.aks_oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.this[each.key].id
  subject             = "system:serviceaccount:${each.value.namespace}:${each.key}"
}
resource "azurerm_key_vault_secret" "workload_identity_client_id" {
  for_each     = var.identities
  name         = "wid-client-id-${each.key}"
  value        = azurerm_user_assigned_identity.this[each.key].client_id
  key_vault_id = each.value.keyvault_id
}