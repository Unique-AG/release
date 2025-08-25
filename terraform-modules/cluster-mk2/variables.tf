variable "kubernetes_version" {
  type        = string
  description = "AKS Kubernetes version to use."
  default     = "1.29"
}
variable "azure_prometheus_grafana_monitor" {
  description = "Specifies a Prometheus-Grafana add-on profile for the Kubernetes Cluster."
  type = object({
    enabled                = bool
    azure_monitor_location = string
    grafana_major_version  = optional(number, 10)
  })
  default = {
    enabled                = false
    azure_monitor_location = "westeurope"
    grafana_major_version  = 10
  }
}
variable "kubernetes_default_node_count_min" {
  type        = number
  description = "Minimum number of nodes in the default node pool."
  default     = 1
}
variable "kubernetes_default_node_count_max" {
  type        = number
  description = "Maximum number of nodes in the default node pool."
  default     = 10
}
variable "kubernetes_cost_analysis_enabled" {
  description = "Enables cost analysis for the AKS cluster. Refer to https://learn.microsoft.com/en-gb/azure/aks/cost-analysis to learn more."
  type        = bool
  default     = true
}
variable "kubernetes_default_node_size" {
  type        = string
  description = "Node size for the default node pool."
  default     = "Standard_D8s_v6"
}
variable "kubernetes_default_node_os_disk_size" {
  type        = number
  description = "OS disk size for the default node pool."
  default     = 100
}
variable "domain_config" {
  type = object({
    name        = string
    sub_domains = list(string)
  })
  description = "FQDN without protocol, where the cluster should be living."
}
variable "monitor_action_group_ids" {
  type = object({
    p0 = optional(string)
    p1 = optional(string)
    p2 = optional(string)
    p3 = optional(string)
    p4 = optional(string)
  })
  description = "Action group ids for responders grouped by alert priority."
  default     = {}
}
variable "gateway" {
  description = "Application gateway parameters."
  type = object({
    sku                         = optional(string, "Standard_v2")
    mode                        = optional(string, "Detection")
    ip_list                     = optional(list(string), [])
    better_uptime               = optional(bool, false)
    file_upload_limit_in_mb     = optional(number, 100)
    max_request_body_size_in_kb = optional(number, 1024)
    global_config = optional(object({
      response_buffering_enabled = bool
      request_buffering_enabled  = bool
    }), null)
    waf = optional(object({
      owasp_rules = optional(list(
        object({
          rule_group_name = string
          rules = list(
            object({
              id      = string
              action  = optional(string, "AnomalyScoring")
              enabled = optional(bool, false)
            })
          )
        })
        ),
        [
          {
            rule_group_name = "REQUEST-913-SCANNER-DETECTION"
            rules           = [{ id = "913101" }]
          },
          {
            rule_group_name = "REQUEST-920-PROTOCOL-ENFORCEMENT"
            rules           = [{ id = "920230" }, { id = "920300" }, { id = "920320" }, { id = "920420" }]
          },
          {
            rule_group_name = "REQUEST-931-APPLICATION-ATTACK-RFI"
            rules           = [{ id = "931130" }]
          },
          {
            rule_group_name = "REQUEST-932-APPLICATION-ATTACK-RCE"
            rules           = [{ id = "932100" }, { id = "932105" }, { id = "932115" }, { id = "932130" }]
          },
          {
            rule_group_name = "REQUEST-933-APPLICATION-ATTACK-PHP"
            rules           = [{ id = "933160" }]
          },
          {
            rule_group_name = "REQUEST-942-APPLICATION-ATTACK-SQLI"
            rules = [
              { id = "942100" },
              { id = "942110" },
              { id = "942130" },
              { id = "942150" },
              { id = "942190" },
              { id = "942200" },
              { id = "942260" },
              { id = "942330" },
              { id = "942340" },
              { id = "942370" },
              { id = "942380" },
              { id = "942410" },
              { id = "942430" },
              { id = "942440" },
              { id = "942450" }
            ]
          }
        ]
      )
      bot_rules = optional(list(
        object({
          rule_group_name = string
          rules = list(
            object({
              id      = string
              action  = optional(string, "AnomalyScoring")
              enabled = optional(bool, false)
            })
          )
        })
        ),
        [
          {
            rule_group_name = "UnknownBots"
            rules = [
              {
                id      = "300300"
                action  = "Log"
                enabled = false
              },
              {
                id      = "300700"
                action  = "Log"
                enabled = false
              }
            ]
          }
        ]
      )
      custom_rules = optional(list(
        object({
          name      = string
          priority  = number
          action    = optional(string, "Block")
          rule_type = optional(string, "MatchRule")
          enabled   = optional(bool, true)
          match_conditions = list(
            object({
              match_variables = list(
                object({
                  variable_name = string
                  selector      = optional(string)
                })
              )
              operator           = string
              match_values       = optional(list(string))
              negation_condition = optional(bool, false)
              transforms         = optional(list(string))
            })
          )
        })
      ), [])
      chat_export_ip_allowlist = optional(list(string), [])
      exclusions = optional(list(
        object({
          match_variable          = string
          selector_match_operator = string
          selector                = string
          excluded_rule_set = optional(object({
            type            = string
            version         = string
            excluded_rules  = optional(list(string), null)
            rule_group_name = string
          }), null)
        })
        ),
        [
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
          },
          {
            match_variable          = "RequestArgNames",
            selector                = "variables.input.text,variables.text"
            selector_match_operator = "EqualsAny"
            excluded_rule_set = {
              type            = "OWASP"
              version         = "3.2"
              rule_group_name = "REQUEST-941-APPLICATION-ATTACK-XSS"
            }
          },
          {
            match_variable          = "RequestArgNames",
            selector                = "variables.input.text,variables.text,variables.input.modules.upsert.create.configuration.systemPromptSearch"
            selector_match_operator = "EqualsAny"
            excluded_rule_set = {
              type            = "OWASP"
              version         = "3.2"
              rule_group_name = "REQUEST-942-APPLICATION-ATTACK-SQLI"
            }
          },
          {
            match_variable          = "RequestArgNames",
            selector                = "variables.input.text,variables.text,variables.input.modules.upsert.create.configuration.systemPromptSearch"
            selector_match_operator = "EqualsAny"
            excluded_rule_set = {
              type            = "OWASP"
              version         = "3.2"
              rule_group_name = "REQUEST-932-APPLICATION-ATTACK-RCE"
            }
          },
          {
            match_variable          = "RequestArgNames",
            selector                = "variables.input.text,variables.text,variables.input.modules.upsert.create.configuration.systemPromptSearch"
            selector_match_operator = "EqualsAny"
            excluded_rule_set = {
              type            = "OWASP"
              version         = "3.2"
              rule_group_name = "REQUEST-933-APPLICATION-ATTACK-PHP"
            }
          },
          {
            match_variable          = "RequestArgNames",
            selector                = "variables.input.text,variables.text,variables.input.modules.upsert.create.configuration.systemPromptSearch"
            selector_match_operator = "EqualsAny"
            excluded_rule_set = {
              type            = "OWASP"
              version         = "3.2"
              rule_group_name = "REQUEST-920-PROTOCOL-ENFORCEMENT"
            }
          },
          {
            match_variable          = "RequestArgNames",
            selector                = "variables.input.text,variables.text,variables.input.modules.upsert.create.configuration.systemPromptSearch"
            selector_match_operator = "EqualsAny"
            excluded_rule_set = {
              type            = "OWASP"
              version         = "3.2"
              rule_group_name = "REQUEST-921-PROTOCOL-ATTACK"
            }
          },
          {
            match_variable          = "RequestArgNames",
            selector                = "variables.input.text,variables.text,variables.input.modules.upsert.create.configuration.systemPromptSearch"
            selector_match_operator = "EqualsAny"
            excluded_rule_set = {
              type            = "OWASP"
              version         = "3.2"
              rule_group_name = "REQUEST-930-APPLICATION-ATTACK-LFI"
            }
          },
          {
            match_variable          = "RequestCookieNames",
            selector                = "__Secure-next-auth.session-token"
            selector_match_operator = "EqualsAny"
            excluded_rule_set = {
              type            = "OWASP"
              version         = "3.2"
              rule_group_name = "REQUEST-942-APPLICATION-ATTACK-SQLI"
            }
          },
        ]
      )
    }), {})
  })
  default = {}
  validation {
    condition     = var.gateway.sku == "Standard_v2" || var.gateway.sku == "WAF_v2"
    error_message = "gateway.sku must be either Standard_v2 or WAF_v2"
  }
  validation {
    condition     = var.gateway.mode == "Detection" || var.gateway.mode == "Prevention"
    error_message = "gateway.mode must be either Detection or Prevention"
  }
  validation {
    condition     = alltrue([for rule in var.gateway.waf.custom_rules : contains(["MatchRule", "RateLimitRule", "Invalid"], rule.rule_type)])
    error_message = "custom_rules.rule_type must be one of: MatchRule, RateLimitRule, Invalid"
  }
  validation {
    condition     = alltrue([for rule in var.gateway.waf.custom_rules : contains(["Allow", "Block", "Log"], rule.action)])
    error_message = "custom_rules.action must be one of: Allow, Block, Log"
  }
  validation {
    condition     = alltrue([for rule in var.gateway.waf.custom_rules : alltrue([for match_cond in rule.match_conditions : alltrue([for match_var in match_cond.match_variables : contains(["RemoteAddr", "RequestMethod", "QueryString", "PostArgs", "RequestUri", "RequestHeaders", "RequestBody", "RequestCookies"], match_var.variable_name)])])])
    error_message = "custom_rules.match_conditions.match_variables.variable_name must be one of: RemoteAddr, RequestMethod, QueryString, PostArgs, RequestUri, RequestHeaders, RequestBody, RequestCookies"
  }
  validation {
    condition     = alltrue([for rule in var.gateway.waf.custom_rules : alltrue([for match_cond in rule.match_conditions : contains(["Any", "IPMatch", "GeoMatch", "Equal", "Contains", "LessThan", "GreaterThan", "LessThanOrEqual", "GreaterThanOrEqual", "BeginsWith", "EndsWith", "Regex"], match_cond.operator)])])
    error_message = "custom_rules.match_conditions.operator must be one of: Any, IPMatch, GeoMatch, Equal, Contains, LessThan, GreaterThan, LessThanOrEqual, GreaterThanOrEqual, BeginsWith, EndsWith, Regex"
  }
  validation {
    condition     = var.gateway.max_request_body_size_in_kb <= 2000
    error_message = "max_request_body_size_in_kb must be less than or equal to 2000"
  }
}
variable "subnet_nodes" {
  type = object({
    id       = string
    name     = string
    cidr     = string
    size     = number
    resource = optional(any, null)
  })
  description = "Subnet object where the Kubernetes nodes should be living."
}
variable "subnet_pods" {
  type = object({
    id       = string
    name     = string
    cidr     = string
    size     = number
    resource = optional(any, null)
  })
  description = "Subnet object where the Kubernetes pods should be living."
}
variable "subnet_appgw" {
  type = object({
    id       = string
    name     = string
    cidr     = string
    size     = number
    resource = optional(any, null)
  })
  description = "Subnet object where the Application Gateway should be living."
}
variable "log_retention_period" {
  type        = number
  description = "Retention period for logs in days. Defaults to 30 days. Must be between 30 and 730 days."
  default     = 30
  validation {
    condition     = var.log_retention_period >= 30 && var.log_retention_period <= 730
    error_message = "log_retention_period must be between 30 and 730 days"
  }
}
variable "storage_retention_period_days" {
  type    = number
  default = 1865
}
variable "storage_delete_retention_days" {
  type        = number
  description = "Retention period for deleted blobs in days."
  default     = 14
}
variable "storage_container_delete_retention_days" {
  type        = number
  description = "Retention period for deleted containers in days."
  default     = 14
}
variable "audit_containers" {
  type    = list(string)
  default = []
}
variable "keyvault_access_principals" {
  type        = list(string)
  description = "Principals that can read the vault"
  default     = []
}
variable "maintenance_window_day" {
  description = "Day of the week for the maintenance window."
  type        = string
  default     = "Saturday"
  validation {
    condition     = contains(["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"], var.maintenance_window_day)
    error_message = "Invalid input given for a maintenance window day. Must be one of: Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday"
  }
}
variable "maintenance_window_start" {
  description = "Start of the maintenance window."
  type        = number
  default     = 10
  validation {
    condition     = var.maintenance_window_start >= 0 && var.maintenance_window_start <= 23
    error_message = "Invalid input given for a maintenance window start. Must be between 0 and 23"
  }
}
variable "maintenance_window_end" {
  description = "End of the maintenance window."
  type        = number
  default     = 14
  validation {
    condition     = var.maintenance_window_end >= 0 && var.maintenance_window_end <= 23
    error_message = "Invalid input given for a maintenance window end. Must be between 0 and 23"
  }
}
variable "azure_aks_diagnostic_logs_categories" {
  description = "Enable diagnostic logs of AKS. Possible categories are: cloud-controller-manager, cluster-autoscaler, csi-azuredisk-controller, csi-azurefile-controller, csi-snapshot-controller, guard, kube-apiserver, kube-audit, kube-audit-admin, kube-controller-manager, kube-scheduler and AllMetrics"
  type        = list(string)
  default     = ["kube-scheduler", "kube-apiserver", "kube-audit", "kube-audit-admin", "kube-controller-manager", "cluster-autoscaler", "cloud-controller-manager"]
}
variable "azure_prometheus_grafana_rabbitmq_alert_enabled" {
  type        = bool
  default     = false
  description = "Enable RabbitMQ prometheus alert"
}
variable "speech_service_private_dns_zone_virtual_network_link_name" {
  type        = string
  description = "Name of the private DNS zone virtual network link"
}
variable "speech_service_private_dns_zone_name" {
  type        = string
  description = "Name of the private DNS zone"
}
variable "virtual_network_id" {
  type        = string
  description = "ID of the virtual network"
}
variable "image_cleaner_interval_hours" {
  type        = number
  description = "Interval in hours for the image cleaner"
  default     = 48
}
variable "auto_scaler_scale_down_unneeded" {
  type        = string
  description = "Scale down unneeded nodes after this amount of time"
  default     = "5m"
}
variable "appgw_5xx_alert_threshold" {
  type        = number
  description = "Threshold for the appgw 5xx alert"
  default     = 8
}