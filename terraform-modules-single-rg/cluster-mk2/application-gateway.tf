locals {
  ip_waf_list = length(var.gateway.ip_list) == 0 ? [] : [{
    name = "IpList"
    list = var.gateway.ip_list
  }]
}
resource "azurerm_public_ip" "appgw" {
  name                = module.context.full_name
  location            = module.context.resource_group.location
  resource_group_name = module.context.resource_group.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
  tags                = module.context.tags
}
resource "azurerm_web_application_firewall_policy" "wafpolicy" {
  count               = var.gateway.sku == "WAF_v2" ? 1 : 0
  name                = "${module.context.full_name}-waf-policy"
  resource_group_name = module.context.resource_group.name
  location            = module.context.resource_group.location
  policy_settings {
    enabled                     = true
    mode                        = var.gateway.mode
    request_body_check          = true
    file_upload_limit_in_mb     = 100
    max_request_body_size_in_kb = 1024
  }
  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
      dynamic "rule_group_override" {
        for_each = var.waf_policy_managed_rule_settings
        content {
          rule_group_name = rule_group_override.value.rule_group_name
          dynamic "rule" {
            for_each = rule_group_override.value.disabled_rule_ids
            content {
              id      = rule.value
              action  = "AnomalyScoring"
              enabled = false
            }
          }
        }
      }
      dynamic "rule_group_override" {
        for_each = var.gateway.waf.owasp_rules
        content {
          rule_group_name = rule_group_override.value.rule_group_name
          dynamic "rule" {
            for_each = rule_group_override.value.disabled_rule_ids
            content {
              id      = rule.value
              action  = "AnomalyScoring"
              enabled = false
            }
          }
        }
      }
    }
    managed_rule_set {
      type    = "Microsoft_BotManagerRuleSet"
      version = "1.0"
      dynamic "rule_group_override" {
        for_each = var.gateway.waf.bot_rules
        content {
          rule_group_name = rule_group_override.value.rule_group_name
          dynamic "rule" {
            for_each = rule_group_override.value.rules
            content {
              id      = rule.value.id
              action  = rule.value.action
              enabled = rule.value.enabled
            }
          }
        }
      }
    }
    dynamic "exclusion" {
      for_each = var.gateway.waf.exclusions
      content {
        match_variable          = exclusion.value.match_variable
        selector_match_operator = exclusion.value.selector_match_operator
        selector                = exclusion.value.selector
        excluded_rule_set {
          type    = exclusion.value.excluded_rule_set.type
          version = exclusion.value.excluded_rule_set.version
          rule_group {
            rule_group_name = exclusion.value.excluded_rule_set.rule_group_name
            excluded_rules  = exclusion.value.excluded_rule_set.excluded_rules
          }
        }
      }
    }
  }
  dynamic "custom_rules" {
    for_each = var.gateway.sku == "WAF_v2" && length(local.ip_waf_list) > 0 ? [1] : []
    content {
      name      = "AllowHttpsChallenges"
      priority  = 1
      rule_type = "MatchRule"
      action    = "Allow"
      match_conditions {
        match_variables {
          variable_name = "RequestHeaders"
          selector      = "User-Agent"
        }
        operator           = "Contains"
        negation_condition = false
        match_values = [
          "https://www.letsencrypt.org"
        ]
        transforms = ["Lowercase"]
      }
      match_conditions {
        match_variables {
          variable_name = "RequestUri"
        }
        operator           = "BeginsWith"
        negation_condition = false
        match_values = [
          "/.well-known/acme-challenge/"
        ]
        transforms = ["Lowercase"]
      }
    }
  }
  dynamic "custom_rules" {
    for_each = local.ip_waf_list
    content {
      name      = custom_rules.value.name
      priority  = 2
      rule_type = "MatchRule"
      match_conditions {
        match_variables {
          variable_name = "RemoteAddr"
        }
        operator           = "IPMatch"
        negation_condition = true
        match_values       = concat(custom_rules.value.list, ["${azurerm_public_ip.this.ip_address}"])
      }
      action = "Block"
    }
  }
  dynamic "custom_rules" {
    for_each = var.gateway.sku == "WAF_v2" ? [1] : []
    content {
      name      = "AllowIngestionUpload"
      priority  = 3
      rule_type = "MatchRule"
      action    = "Allow"
      match_conditions {
        match_variables {
          variable_name = "RequestUri"
        }
        operator           = "BeginsWith"
        negation_condition = false
        match_values = [
          "/scoped/ingestion/upload",
          "/ingestion/v1/content"
        ]
        transforms = ["Lowercase"]
      }
    }
  }
  dynamic "custom_rules" {
    for_each = var.gateway.sku == "WAF_v2" && length(var.gateway.waf.custom_rules) > 0 ? var.gateway.waf.custom_rules : []
    content {
      name      = custom_rules.value.name
      priority  = lookup(custom_rules.value, "priority", 100)
      rule_type = lookup(custom_rules.value, "rule_type", "MatchRule")
      action    = lookup(custom_rules.value, "action", "Block")
      enabled   = lookup(custom_rules.value, "enabled", true)
      dynamic "match_conditions" {
        for_each = custom_rules.value.match_conditions
        content {
          dynamic "match_variables" {
            for_each = match_conditions.value.match_variables
            content {
              variable_name = match_variables.value.variable_name
              selector      = match_variables.value.selector
            }
          }
          operator           = match_conditions.value.operator
          negation_condition = lookup(match_conditions.value, "negation_condition", null)
          match_values       = lookup(match_conditions.value, "match_values", [])
          transforms         = lookup(match_conditions.value, "transforms", null)
        }
      }
    }
  }
  dynamic "custom_rules" {
    for_each = length(var.gateway.waf.chat_export_ip_allowlist) > 0 ? [1] : []
    content {
      name      = "ChatExportAdminRouteIpRestriction"
      priority  = 3
      rule_type = "MatchRule"
      action    = "Block"
      match_conditions {
        match_variables {
          variable_name = "RemoteAddr"
        }
        operator           = "IPMatch"
        negation_condition = true
        match_values       = var.gateway.waf.chat_export_ip_allowlist
      }
      match_conditions {
        transforms = ["Lowercase"]
        match_variables {
          variable_name = "RequestUri"
        }
        operator     = "BeginsWith"
        match_values = ["/chat/analytics/user-chat-export"]
      }
    }
  }
}
locals {
  sku_suffix = var.gateway.sku == "WAF_v2" ? "" : "-std"
}
resource "azurerm_application_gateway" "appgw" {
  name                = "${module.context.full_name}${local.sku_suffix}"
  location            = module.context.resource_group.location
  resource_group_name = module.context.resource_group.name
  enable_http2        = true
  sku {
    name = var.gateway.sku
    tier = var.gateway.sku
  }
  autoscale_configuration {
    min_capacity = 2
    max_capacity = 5
  }
  backend_address_pool {
    name = "defaultaddresspool"
  }
  backend_http_settings {
    name                  = "defaulthttpsetting"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }
  frontend_ip_configuration {
    name                 = module.context.full_name
    public_ip_address_id = azurerm_public_ip.appgw.id
  }
  frontend_ip_configuration {
    name                          = "${module.context.full_name}-internal"
    private_ip_address            = cidrhost(var.subnet_appgw.cidr, 6)
    private_ip_address_allocation = "Static"
    subnet_id                     = var.subnet_appgw.id
  }
  frontend_port {
    name = "http"
    port = 80
  }
  gateway_ip_configuration {
    name      = module.context.full_name
    subnet_id = var.subnet_appgw.id
  }
  http_listener {
    name                           = "http"
    frontend_ip_configuration_name = module.context.full_name
    frontend_port_name             = "http"
    protocol                       = "Http"
  }
  request_routing_rule {
    backend_address_pool_name  = "defaultaddresspool"
    backend_http_settings_name = "defaulthttpsetting"
    http_listener_name         = "http"
    name                       = "defaultroutingrule"
    priority                   = 19500
    rule_type                  = "Basic"
  }
  ssl_policy {
    policy_name = "AppGwSslPolicy20220101"
    policy_type = "Predefined"
  }
  rewrite_rule_set {
    name = "security-headers"
    rewrite_rule {
      name          = "set-hsts-header"
      rule_sequence = 100
      response_header_configuration {
        header_name  = "Strict-Transport-Security"
        header_value = "max-age=31536000; includeSubDomains"
      }
    }
    rewrite_rule {
      name          = "set-nosniff-header"
      rule_sequence = 101
      response_header_configuration {
        header_name  = "X-Content-Type-Options"
        header_value = "nosniff"
      }
    }
    rewrite_rule {
      name          = "set-xss-header"
      rule_sequence = 102
      response_header_configuration {
        header_name  = "X-XSS-Protection"
        header_value = "1; mode=block"
      }
    }
    rewrite_rule {
      name          = "set-ref-header"
      rule_sequence = 103
      response_header_configuration {
        header_name  = "Referrer-Policy"
        header_value = "same-origin"
      }
    }
    rewrite_rule {
      name          = "delete-server-header"
      rule_sequence = 104
      response_header_configuration {
        header_name  = "Server"
        header_value = ""
      }
    }
  }
  firewall_policy_id = var.gateway.sku == "WAF_v2" ? azurerm_web_application_firewall_policy.wafpolicy[0].id : null
  tags               = module.context.tags
  lifecycle {
    ignore_changes = [
      backend_http_settings,
      backend_address_pool,
      probe,
      frontend_port,
      http_listener,
      rewrite_rule_set,
      redirect_configuration,
      request_routing_rule,
      ssl_certificate,
      url_path_map,
      tags["ingress-for-aks-cluster-id"],
      tags["managed-by-k8s-ingress"]
    ]
  }
}
resource "azurerm_monitor_diagnostic_setting" "waf" {
  name                       = "${module.context.full_name}-waflog"
  target_resource_id         = azurerm_application_gateway.appgw.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  enabled_log {
    category = "ApplicationGatewayFirewallLog"
  }
  enabled_log {
    category = "ApplicationGatewayAccessLog"
  }
  enabled_log {
    category = "ApplicationGatewayPerformanceLog"
  }
  metric {
    category = "AllMetrics"
    enabled  = false
  }
}
resource "azurerm_role_assignment" "rg_reader_agic" {
  scope                = module.context.resource_group.id
  role_definition_name = "Reader"
  principal_id         = azurerm_kubernetes_cluster.this.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
}
resource "azurerm_role_assignment" "network_contributor_agic" {
  scope                = var.subnet_appgw.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.this.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
}
resource "azurerm_role_assignment" "appgw_contributor_agic" {
  scope                = azurerm_application_gateway.appgw.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_kubernetes_cluster.this.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
}