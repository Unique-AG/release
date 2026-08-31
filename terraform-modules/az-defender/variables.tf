variable "cspm_full" {
  type        = bool
  default     = false
  description = "Enable full CSPM"
}
variable "enable_cspm" {
  type        = bool
  default     = true
  description = "Enable Cloud Security Posture Management (free unless cspm_full is true)."
}
variable "enable_cwp_storage" {
  type        = bool
  default     = true
  description = "Enable Defender for Storage v2 with on-upload malware scanning. Required for node-ingestion ENABLE_MALWARE_SCAN: the app waits for blob index tag 'Malware Scanning scan result'."
}
variable "enable_cwp_servers" {
  type        = bool
  default     = false
  description = "Enable Defender for Servers (P2). Off by default to avoid unexpected cost."
}
variable "enable_cwp_keyvaults" {
  type        = bool
  default     = false
  description = "Enable Defender for Key Vaults."
}
variable "enable_cwp_resourcemanager" {
  type        = bool
  default     = false
  description = "Enable Defender for Resource Manager."
}
variable "enable_cwp_opensourcerelationaldb" {
  type        = bool
  default     = false
  description = "Enable Defender for open-source relational databases."
}
variable "enable_security_contact" {
  type        = bool
  default     = false
  description = "Create the subscription security contact. Off by default because the default contact may already exist."
}
variable "security_contact_email" {
  type        = string
  default     = "security-events@unique.ch"
  description = "Email address to send security alerts to."
}
variable "cwp_storage_cap_gb" {
  type        = string
  default     = "1000"
  description = "The maximum amount of data that will be scanned per month in GB."
}
variable "vm_exclusion_tags" {
  type        = string
  default     = "[]"
  description = "List of tags to exclude from VM scanning."
}