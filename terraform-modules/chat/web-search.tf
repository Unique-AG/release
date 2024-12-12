resource "azurerm_resource_group_template_deployment" "argtd_bing_search_v7" {
  name                = module.context.full_name
  resource_group_name = module.context.rg_app_main.name
  deployment_mode     = "Incremental"
  parameters_content = jsonencode({
    "name" = {
      value = module.context.full_name
    },
    "location" = {
      value = "Global"
    },
    "sku" = {
      value = var.bing_search_v7_sku_name
    },
    "kind" = {
      value = "Bing.Search.v7"
    }
  })
  template_content = file("${path.module}/bing-resource-template.json")
}