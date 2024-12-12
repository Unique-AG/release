variable "cspm_full" {
  type        = bool
  default     = false
  description = "Enable full CSPM"
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