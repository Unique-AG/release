variable "p0_email_addresses" {
  type = map(object({
    email_address = string
  }))
  description = "Email addresses for p0 alerts"
}