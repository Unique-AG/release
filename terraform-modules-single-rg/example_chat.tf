locals {
  base_subnet   = "10.113.0.0/16"
  project       = "client"
  project_child = "moduleName"
  environment   = "zone"
  locations = {
    deployment = "germanywestcentral"
    monitor    = "germanywestcentral"
    openai     = "francecentral"
  }
  base_domain         = "client.unique.app"
  management_group_id = "uqe-lz-${local.project}"
}
module "context" {
  source      = "./context"
  namespace   = "uq"
  project     = local.project
  environment = local.environment
  resource_group = {
    id       = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}"
    name     = var.resource_group_name
    location = local.locations.deployment
  }
  tags = {
    ManagedBy   = "Terraform"
    Client      = local.project
    Environment = local.environment
  }
}
module "vnet" {
  source      = "./vnet"
  context     = module.context
  base_subnet = local.base_subnet
  subnets = [
    {
      name = "AppGW"
      size = 28
    },
    {
      name                                      = "TykRedis",
      size                                      = 28
      private_endpoint_network_policies_enabled = false
    },
    {
      name = "Postgres"
      size = 28
      delegations = [
        {
          name = "fs"
          service_delegations = [{
            name = "Microsoft.DBforPostgreSQL/flexibleServers"
            actions = [
              "Microsoft.Network/virtualNetworks/subnets/join/action",
            ]
          }]
        }
      ]
      service_endpoints = ["Microsoft.Storage"]
    },
    {
      name = "AzureBastionSubnet"
      size = 26
    },
    {
      name = "Jumpbox"
      size = 28
    },
    {
      name              = "AksNodes"
      size              = 24
      service_endpoints = ["Microsoft.Storage"]
    },
    {
      name = "AksPods"
      size = 20
      delegations = [
        {
          name = "aks-delegation"
          service_delegations = [{
            actions = [
              "Microsoft.Network/virtualNetworks/subnets/join/action",
            ]
            name = "Microsoft.ContainerService/managedClusters"
          }]
        }
      ]
      service_endpoints = ["Microsoft.Storage"]
    },
  ]
}
module "monitor" {
  source  = "./az-monitor"
  context = module.context
  action_group_list = {
    "slack-platform" = {
      email_addresses = ["recipient@example.com"]
    },
  }
}
module "cluster" {
  source                        = "./cluster-mk2"
  context                       = module.context
  subnet_nodes                  = module.vnet.subnets["AksNodes"]
  subnet_pods                   = module.vnet.subnets["AksPods"]
  subnet_appgw                  = module.vnet.subnets["AppGW"]
  storage_retention_period_days = 1865
  keyvault_access_principals    = [module.jumpbox.vm_identity, module.cluster.key_vault_secrets_provider.secret_identity[0].object_id]
  kubernetes_default_node_size  = "Standard_D8s_v5"
  kubernetes_version            = "1.27.7"
  domain_config = {
    name        = local.base_domain
    sub_domains = ["gateway", "id", "argo"]
  }
  azure_prometheus_grafana_monitor = {
    enabled                = true
    azure_monitor_location = local.locations.monitor
  }
  audit_containers = [
    "node-chat",
    "node-ingestion",
    "node-ingestion-worker",
    "node-ingestion-worker-chat",
  ]
  aks_services_alerts_rules = {
    "Rabbitmq_is_down" = {
      enabled = true
      receivers = [
        module.monitor.monitor_action_group_ids.slack-platform
      ]
    }
    "Rabbitmq_Queue_Messages" = {
      enabled = true
      receivers = [
        module.monitor.monitor_action_group_ids.slack-platform
      ]
    }
    "Rabbitmq_Queue_Messages_Unacked" = {
      enabled = true
      receivers = [
        module.monitor.monitor_action_group_ids.slack-platform
      ]
    }
  }
  azure_alerts = {
    "appgw" = {
      enabled         = true
      action_group_id = try(module.monitor.monitor_action_group_ids.slack-platform, null)
    }
  }
}
module "jumpbox" {
  source                     = "./jumpbox"
  name                       = "jumpbox"
  context                    = module.context
  jumpbox_subnet             = module.vnet.subnets["Jumpbox"]
  bastion_subnet             = module.vnet.subnets["AzureBastionSubnet"]
  log_analytics_workspace_id = module.cluster.log_analytics_workspace_id
  cloud_init_scripts_version = "2024-04"
}
module "postgres" {
  source                     = "./postgres"
  name                       = local.project_child
  context                    = module.context
  flex_storage_mb            = 131072
  virtual_network_id         = module.vnet.virtual_network_id
  delegated_subnet_id        = module.vnet.subnets["Postgres"].id
  keyvault_access_principals = [module.jumpbox.vm_identity, module.cluster.key_vault_secrets_provider.secret_identity[0].object_id]
}
module "workload_identities" {
  source              = "./az-workload-identity"
  context             = module.context
  aks_oidc_issuer_url = module.cluster.aks_oidc_issuer_url
  management_group_id = local.management_group_id
  identities = {
    node-chat = {
      keyvault_id = module.chat.keyvault_id
      namespace   = "chat"
      roles       = ["Cognitive Services OpenAI User"]
    }
    node-ingestion = {
      keyvault_id = module.chat.keyvault_id
      namespace   = "chat"
      roles       = ["Cognitive Services OpenAI User"]
    }
    node-ingestion-worker = {
      keyvault_id = module.chat.keyvault_id
      namespace   = "chat"
      roles       = ["Cognitive Services User" /* Document Intelligence */]
    }
    node-ingestion-worker-chat = {
      keyvault_id = module.chat.keyvault_id
      namespace   = "chat"
      roles       = ["Cognitive Services User" /* Document Intelligence */]
    }
    assistants-core = {
      keyvault_id = module.chat.keyvault_id
      namespace   = "chat"
      roles       = ["Cognitive Services User" /* Document Intelligence */]
    }
  }
}
module "chat" {
  source                         = "./chat"
  name                           = "chat"
  context                        = module.context
  openai_account_location        = local.locations.openai
  keyvault_access_principals     = [module.jumpbox.vm_identity, module.cluster.key_vault_secrets_provider.secret_identity[0].object_id]
  database_keyvault_id           = module.postgres.database_keyvault_id
  aks_oidc_issuer_url            = module.cluster.aks_oidc_issuer_url
  gpt_35_turbo_tpm_thousands     = 120
  gpt_35_turbo_16k_tpm_thousands = 120
  storage_account_cors_rules = [
    {
      allowed_origins    = ["https://${local.base_domain}"]
      allowed_methods    = ["OPTIONS", "PUT", "GET"]
      allowed_headers    = ["*"]
      exposed_headers    = ["*"]
      max_age_in_seconds = 3600
    },
    {
      allowed_origins    = ["https://*.${local.base_domain}"]
      allowed_methods    = ["OPTIONS", "PUT", "GET"]
      allowed_headers    = ["*"]
      exposed_headers    = ["*"]
      max_age_in_seconds = 3600
    },
  ]
  azure_openai_endpoints                = [module.swedencentral.endpoints]
  azure_document_intelligence_endpoints = []
  postgres_server_id                    = module.postgres.server_id
  user_assigned_identity_ids = [
    module.workload_identities.user_assigned_identity_ids["node-chat"],
    module.workload_identities.user_assigned_identity_ids["node-ingestion"],
    module.workload_identities.user_assigned_identity_ids["node-ingestion-worker"]
  ]
}
module "automation" {
  source                     = "./automation"
  name                       = "automation"
  context                    = module.context
  keyvault_access_principals = [module.jumpbox.vm_identity, module.cluster.key_vault_secrets_provider.secret_identity[0].object_id]
}
module "tyk" {
  source                     = "./az-redis"
  name                       = "tyk"
  context                    = module.context
  subnet_pods                = module.vnet.subnets["AksPods"]
  subnet_redis               = module.vnet.subnets["TykRedis"]
  keyvault_access_principals = [module.jumpbox.vm_identity, module.cluster.key_vault_secrets_provider.secret_identity[0].object_id]
  virtual_network_id         = module.vnet.virtual_network_id
  monitor_action_group_ids = {
    p0 = module.monitor.monitor_action_group_ids.slack-platform
  }
}
module "ad-app-registration" {
  source      = "./aad-app-registration"
  context     = module.context
  keyvault_id = module.chat.keyvault_id
  redirect_uris = [
    "https://id.${local.base_domain}/ui/login/login/externalidp/callback",
  ]
}
module "defender" {
  source  = "./az-defender"
  context = module.context
}
module "swedencentral" {
  source           = "./az-openai"
  context          = module.context
  account_location = "swedencentral"
  deployments = {
    "gpt-4o-2024-05-13" = {
      name          = "gpt-4o-2024-05-13"
      model_name    = "gpt-4o"
      model_version = "2024-05-13"
      sku_name      = "Standard"
      sku_capacity  = 1000
    }
    "gpt-4o-mini-2024-07-18" = {
      name          = "gpt-4o-mini-2024-07-18"
      model_name    = "gpt-4o-mini"
      model_version = "2024-07-18"
      sku_name      = "Standard"
      sku_capacity  = 1000
    }
  }
  user_assigned_identity_ids = [
    module.workload_identities.user_assigned_identity_ids["node-chat"],
  ]
}
module "aad-app-registration-gitops" {
  source                           = "./aad-app-registration-mk2"
  display_name                     = "[${module.context.project}-${module.context.environment}] GITOPS"
  keyvault_id                      = module.automation.keyvault_id
  aad-app-secret-display-name      = "${module.context.project}-${module.context.environment}-gitops"
  maintainers_principal_object_ids = ["99999999-9999-9999-9999-999999999999"]
  redirect_uris = [
    "https://argo.client.unique.app/auth/callback",
  ]
  required_resource_access_list = {
    "99999999-9999-9999-9999-999999999999" = [
      {
        id   = "99999999-9999-9999-9999-999999999999"
        type = "Scope"
      },
      {
        id   = "99999999-9999-9999-9999-999999999999"
        type = "Scope"
      },
      {
        id   = "99999999-9999-9999-9999-999999999999"
        type = "Scope"
      },
      {
        id   = "99999999-9999-9999-9999-999999999999"
        type = "Scope"
      },
    ],
  }
}