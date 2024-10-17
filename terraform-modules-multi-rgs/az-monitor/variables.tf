variable "action_group_list" {
  description = "A list of action groups"
  type = map(object({
    severity        = string
    email_addresses = list(string)
  }))
  default = {
  }
}