locals {
  base_subnet   = "10.118.0.0/16"
  project       = "client"
  project_child = "moduleName"
  environment   = "sb"
  locations = {
    deployment = var.location_deployment
    monitor    = var.location_monitor
    openai     = var.location_openai
  }
  base_domain         = "sb-client.unique.app"
  management_group_id = "uqe-sb"
}
module "context" {
  source      = "./modules/context"
  namespace   = "uq"
  project     = local.project
  environment = local.environment
  rg_app_main = {
    id       = data.azurerm_resource_group.app_main.id
    name     = data.azurerm_resource_group.app_main.name
    location = data.azurerm_resource_group.app_main.location
  }
  rg_app_net = {
    id       = data.azurerm_resource_group.app_net.id
    name     = data.azurerm_resource_group.app_net.name
    location = data.azurerm_resource_group.app_net.location
  }
  rg_app_tf = {
    id       = data.azurerm_resource_group.app_tf.id
    name     = data.azurerm_resource_group.app_tf.name
    location = data.azurerm_resource_group.app_tf.location
  }
  rg_app_sec = {
    id       = data.azurerm_resource_group.app_sec.id
    name     = data.azurerm_resource_group.app_sec.name
    location = data.azurerm_resource_group.app_sec.location
  }
  rg_app_audit = {
    id       = data.azurerm_resource_group.app_audit.id
    name     = data.azurerm_resource_group.app_audit.name
    location = data.azurerm_resource_group.app_audit.location
  }
  tags = {
    ManagedBy = "Terraform"
  }
}
module "vnet" {
  source      = "./modules/vnet"
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
  source  = "./modules/az-monitor"
  context = module.context
  action_group_list = {
    "slack-platform" = {
      severity        = "p0"
      email_addresses = ["recipient@example.com"]
    },
  }
}
module "cluster" {
  source                        = "./modules/cluster-mk2"
  context                       = module.context
  subnet_nodes                  = module.vnet.subnets["AksNodes"]
  subnet_pods                   = module.vnet.subnets["AksPods"]
  subnet_appgw                  = module.vnet.subnets["AppGW"]
  storage_retention_period_days = 1865
  keyvault_access_principals    = [module.jumpbox.vm_identity]
  kubernetes_default_node_size  = var.kubernetes_default_node_size
  kubernetes_version            = var.kubernetes_version
  domain_config = {
    name        = local.base_domain
    sub_domains = ["gateway", "id"]
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
  monitor_action_group_ids = {
    p0 = module.monitor.monitor_action_group_ids.slack-platform
    p1 = module.monitor.monitor_action_group_ids.slack-platform
    p2 = module.monitor.monitor_action_group_ids.slack-platform
    p3 = module.monitor.monitor_action_group_ids.slack-platform
    p4 = module.monitor.monitor_action_group_ids.slack-platform
  }
  gateway = {
    sku  = "WAF_v2"
    mode = "Prevention"
    waf = {
      owasp_rules = [
        {
          rule_group_name   = "REQUEST-920-PROTOCOL-ENFORCEMENT"
          disabled_rule_ids = ["920230", "920300", "920320", "920420"]
        },
        {
          rule_group_name   = "REQUEST-931-APPLICATION-ATTACK-RFI"
          disabled_rule_ids = ["931130"]
        },
        {
          rule_group_name   = "REQUEST-932-APPLICATION-ATTACK-RCE"
          disabled_rule_ids = ["932100", "932105", "932115", "932130"]
        },
        {
          rule_group_name   = "REQUEST-942-APPLICATION-ATTACK-SQLI"
          disabled_rule_ids = ["942100", "942110", "942130", "942150", "942190", "942200", "942260", "942330", "942340", "942370", "942380", "942410", "942430", "942440", "942450"]
        }
      ]
      bot_rules = []
      exclusions = [
        {
          match_variable          = "RequestArgNames",
          selector                = "variables.input.favicon,variables.input.logoHeader,variables.input.logoNavbar"
          selector_match_operator = "EqualsAny"
          excluded_rule_set = {
            type            = "OWASP"
            version         = "3.2"
            excluded_rules  = ["941130", "941170"]
            rule_group_name = "REQUEST-941-APPLICATION-ATTACK-XSS"
          }
        }
      ]
      custom_rules = [
        {
          name     = "AllowSpecificUrlsInHostHeader"
          action   = "Allow"
          priority = 99
          match_conditions = [
            {
              match_variables = [{
                variable_name = "RequestHeaders",
                selector      = "host"
              }]
              operator     = "Contains"
              match_values = ["kubernetes.default.svc", "github.com/Unique-AG/monorepo"]
            }
          ]
        }
      ]
    }
  }
  waf_policy_managed_rule_settings = []
}
module "jumpbox" {
  source                     = "./modules/jumpbox"
  name                       = "jumpbox"
  context                    = module.context
  jumpbox_subnet             = module.vnet.subnets["Jumpbox"]
  bastion_subnet             = module.vnet.subnets["AzureBastionSubnet"]
  log_analytics_workspace_id = module.cluster.log_analytics_workspace_id
  cloud_init_scripts_version = "2024-04"
}
module "postgres" {
  source                     = "./modules/postgres"
  name                       = local.project_child
  context                    = module.context
  flex_storage_mb            = 131072
  virtual_network_id         = module.vnet.virtual_network_id
  delegated_subnet_id        = module.vnet.subnets["Postgres"].id
  keyvault_access_principals = [module.jumpbox.vm_identity]
}
module "workload_identities" {
  source              = "./modules/az-workload-identity"
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
  source                     = "./modules/chat"
  name                       = "chat"
  context                    = module.context
  openai_account_location    = local.locations.openai
  keyvault_access_principals = [module.jumpbox.vm_identity]
  aks_oidc_issuer_url        = module.cluster.aks_oidc_issuer_url
  database_keyvault_id       = module.postgres.database_keyvault_id
  openai_deployments         = var.openai_deployments
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
  azure_openai_endpoints                           = []
  azure_document_intelligence_endpoints            = [module.document-ingelligence-switzerlandnorth.endpoint]
  azure_document_intelligence_endpoint_definitions = [module.document-ingelligence-switzerlandnorth.endpoint_definition]
  postgres_server_id                               = module.postgres.server_id
  user_assigned_identity_ids = [
    module.workload_identities.user_assigned_identity_ids["node-chat"],
    module.workload_identities.user_assigned_identity_ids["node-ingestion"],
    module.workload_identities.user_assigned_identity_ids["node-ingestion-worker"]
  ]
}
module "automation" {
  source                     = "./modules/automation"
  name                       = "automation"
  context                    = module.context
  keyvault_access_principals = [module.jumpbox.vm_identity]
}
module "tyk" {
  source                     = "./modules/az-redis"
  name                       = "tyk"
  context                    = module.context
  subnet_pods                = module.vnet.subnets["AksPods"]
  subnet_redis               = module.vnet.subnets["TykRedis"]
  keyvault_access_principals = [module.jumpbox.vm_identity]
  virtual_network_id         = module.vnet.virtual_network_id
  monitor_action_group_ids = {
    p0 = module.monitor.monitor_action_group_ids.slack-platform
  }
}
module "document-ingelligence-switzerlandnorth" {
  source           = "./modules/az-document-intelligence"
  context          = module.context
  account_location = "switzerlandnorth"
  user_assigned_identity_ids = [
    module.workload_identities.user_assigned_identity_ids["node-ingestion-worker"],
    module.workload_identities.user_assigned_identity_ids["assistants-core"],
    module.workload_identities.user_assigned_identity_ids["node-ingestion-worker-chat"],
  ]
}