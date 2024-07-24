variable "kubernetes_version" {
  type        = string
  description = "AKS Kubernetes version to use."
  default     = "1.27.7"
}
variable "azure_prometheus_grafana_monitor" {
  description = "Specifies a Prometheus-Grafana add-on profile for the Kubernetes Cluster."
  type = object({
    enabled                = bool
    azure_monitor_location = string
  })
  default = {
    enabled                = false
    azure_monitor_location = "westeurope"
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
variable "kubernetes_default_node_size" {
  type        = string
  description = "Node size for the default node pool."
  default     = "Standard_D8s_v5"
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
  description = "Application gateway WAF parameters."
  type = object({
    sku     = optional(string, "Standard_v2")
    mode    = optional(string, "Detection")
    ip_list = optional(list(string), [])
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
variable "waf_policy_managed_rule_settings" {
  type = list(
    object(
      {
        rule_group_name   = string
        disabled_rule_ids = list(string)
      }
    )
  )
  default = [
    {
      rule_group_name = "General"
      disabled_rule_ids = [
        "200002",
        "200003",
        "200004"
      ]
    },
    {
      rule_group_name = "REQUEST-911-METHOD-ENFORCEMENT"
      disabled_rule_ids = [
        "911100"
      ]
    },
    {
      rule_group_name = "REQUEST-913-SCANNER-DETECTION"
      disabled_rule_ids = [
        "913100",
        "913101",
        "913102",
        "913110",
        "913120"
      ]
    },
    {
      rule_group_name = "REQUEST-920-PROTOCOL-ENFORCEMENT"
      disabled_rule_ids = [
        "920100",
        "920120",
        "920121",
        "920160",
        "920170",
        "920171",
        "920180",
        "920190",
        "920200",
        "920201",
        "920202",
        "920210",
        "920220",
        "920230",
        "920240",
        "920250",
        "920260",
        "920270",
        "920271",
        "920272",
        "920273",
        "920274",
        "920280",
        "920290",
        "920300",
        "920310",
        "920311",
        "920320",
        "920330",
        "920340",
        "920341",
        "920350",
        "920420",
        "920430",
        "920440",
        "920450",
        "920460",
        "920470",
        "920480"
      ]
    },
    {
      rule_group_name = "REQUEST-921-PROTOCOL-ATTACK"
      disabled_rule_ids = [
        "921110",
        "921120",
        "921130",
        "921140",
        "921150",
        "921151",
        "921160",
        "921170",
        "921180"
      ]
    },
    {
      rule_group_name = "REQUEST-930-APPLICATION-ATTACK-LFI"
      disabled_rule_ids = [
        "930100",
        "930110",
        "930120",
        "930130"
      ]
    },
    {
      rule_group_name = "REQUEST-931-APPLICATION-ATTACK-RFI"
      disabled_rule_ids = [
        "931100",
        "931110",
        "931120",
        "931130"
      ]
    },
    {
      rule_group_name = "REQUEST-932-APPLICATION-ATTACK-RCE"
      disabled_rule_ids = [
        "932100",
        "932105",
        "932106",
        "932110",
        "932115",
        "932120",
        "932130",
        "932140",
        "932150",
        "932160",
        "932170",
        "932171",
        "932180",
        "932190"
      ]
    },
    {
      rule_group_name = "REQUEST-933-APPLICATION-ATTACK-PHP"
      disabled_rule_ids = [
        "933100",
        "933110",
        "933111",
        "933120",
        "933130",
        "933131",
        "933140",
        "933150",
        "933151",
        "933160",
        "933161",
        "933170",
        "933180",
        "933190",
        "933200",
        "933210"
      ]
    },
    {
      rule_group_name = "REQUEST-941-APPLICATION-ATTACK-XSS"
      disabled_rule_ids = [
        "941100",
        "941101",
        "941110",
        "941120",
        "941130",
        "941140",
        "941150",
        "941160",
        "941170",
        "941180",
        "941190",
        "941200",
        "941210",
        "941220",
        "941230",
        "941240",
        "941250",
        "941260",
        "941270",
        "941280",
        "941290",
        "941300",
        "941310",
        "941320",
        "941330",
        "941340",
        "941350",
        "941360"
      ]
    },
    {
      rule_group_name = "REQUEST-942-APPLICATION-ATTACK-SQLI"
      disabled_rule_ids = [
        "942100",
        "942110",
        "942120",
        "942130",
        "942140",
        "942150",
        "942160",
        "942170",
        "942180",
        "942190",
        "942200",
        "942210",
        "942220",
        "942230",
        "942240",
        "942250",
        "942251",
        "942260",
        "942270",
        "942280",
        "942290",
        "942300",
        "942310",
        "942320",
        "942330",
        "942340",
        "942350",
        "942360",
        "942361",
        "942370",
        "942380",
        "942390",
        "942400",
        "942410",
        "942420",
        "942421",
        "942430",
        "942431",
        "942432",
        "942440",
        "942450",
        "942460",
        "942470",
        "942480",
        "942490",
        "942500"
      ]
    },
    {
      rule_group_name = "REQUEST-943-APPLICATION-ATTACK-SESSION-FIXATION"
      disabled_rule_ids = [
        "943100",
        "943110",
        "943120"
      ]
    },
    {
      rule_group_name = "REQUEST-944-APPLICATION-ATTACK-JAVA"
      disabled_rule_ids = [
        "944100",
        "944110",
        "944120",
        "944130",
        "944200",
        "944210",
        "944240",
        "944250"
      ]
    },
    {
      rule_group_name = "Known-CVEs"
      disabled_rule_ids = [
        "800100",
        "800110",
        "800111",
        "800112",
        "800113"
  ] }]
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