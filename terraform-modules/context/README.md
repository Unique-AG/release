# Terraform module pass context to other modules

This module helps with a naming convention and passing shared information to other modules.

## Variables

`context` - Single object to hold all context variables. Using indivial variables will override settings in this object.
`name` - The name of component the resource belongs to. This is usually the name of the application or service.
`namespace` - Value to use as a namespace for resources. This is usually a short abbreviation of your company name or project name.
`project` - When resource are dedictated per customer, this name can be used to identify the customer the resource is for. This is usually a short abbreviation for the customer name.
`environment` - A short abbreviation for the environment, e.g. dev, test, prod.
`tags` - A map of tags to add to all resources.
`resource_group` - The resource group to deploy resources to.

## Naming convention

The naming convention is as follows:

`<namespace>-[<project>]-<environment>-[<name>]`

- `namespace` is a short name for the project, e.g. `uq`
- `project` is a optional name for the project or customer.
- `environment` is a short name for the environment, e.g. `dev`
- `name` is a optional name for the resource, e.g. `chat`

When the module gets initialized with following values:

```hcl
module "context" {
  source = "../../modules/context"

  name        = "chat"
  namespace   = "unique"
  project     = "acme"
  environment = "dev"
}
```

`module.context.full_name` will be `unique-acme-dev-chat`.


When the module gets initialized with following values:

```hcl
module "context" {
  source = "../../modules/context"

  namespace   = "unique"
  environment = "qa"
}
```
`module.context.full_name` will be `unique-qa` and compatible with the naming convention of the qa/prod environment.

## Example

Terraform project root:

```hcl
module "context" {
  source = "../../modules/context"

  namespace   = "unique"
  project     = "lion"
  environment = "dev"

  resource_group = {
    id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example"
    name     = "example"
    location = "westeurope"
  }

  tags = {
    "made-by" = "terraform"
  }
}

module "myservicename" {
  source = "../../modules/servicemodule"

  name     = "myservicename"
  context  = module.context

  version  = "latest"    
}
```


Terraform "servicemodule" module:

Copy the `example/context.tf` file from this module into your module folder and use it like this:


```hcl
variable "version" {
  type = string
}

resource "azurerm_storage_account" "example" {
  name                     = module.context.full_name_no_dashes_truncated  # name will be "uniqueliondevmyseubmq28"
  resource_group_name      = module.context.resource_group.name
  location                 = module.context.resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = module.context.tags
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = module.context.full_name  # name will be "unique-lion-dev-myservicename" || ->> not the case for letter cluster
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = module.context.tags
}

resource "azurerm_container_app_environment" "example" {
  name                       = module.context.full_name  # name will be "unique-lion-dev-myservicename"
  location                   = azurerm_resource_group.example.location
  resource_group_name        = azurerm_resource_group.example.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  tags = module.context.tags
}

resource "azurerm_container_app" "example" {
  name                         = module.context.full_name  # name will be "unique-lion-dev-myservicename"
  container_app_environment_id = azurerm_container_app_environment.example.id
  resource_group_name          = azurerm_resource_group.example.name
  revision_mode                = "Single"

  template {
    container {
      name   = "examplecontainerapp"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:${var.version}"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  tags = module.context.tags
}
```