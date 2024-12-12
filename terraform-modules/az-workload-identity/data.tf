data "azurerm_resource_group" "rg_app_main" {
  name = module.context.rg_app_main.name
}
data "azurerm_resource_group" "rg_app_sec" {
  name = module.context.rg_app_sec.name
}