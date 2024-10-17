variable "action_group_list" {
  description = "A list of action groups"
  type = map(object({
    email_addresses = list(string)
  }))
  default = {
    "slack-platform" = {
      email_addresses = ["email-from-slack-channel@slack.com"]
    },
  }
}