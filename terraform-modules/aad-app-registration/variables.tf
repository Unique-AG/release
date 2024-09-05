variable "keyvault_id" {
  type        = string
  description = "Keyvault where to store the app credentials"
}
variable "redirect_uris" {
  description = "Authorized redirects"
  default     = []
}
variable "redirect_uris_public_native" {
  description = "Public client/native (mobile & desktop) redirects"
  default     = []
}
variable "use_intune" {
  description = "If single-tenant uses intune, adds required scope"
  default     = false
}
variable "owner_user_object_ids" {
  type    = list(string)
  default = []
}
variable "required_resource_access_list" {
  description = "A map of resource_app_ids with their access configurations."
  type = map(list(object({
    name = string
    id   = string
    type = string
  })))
  default = {
    "00000003-0000-0000-c000-000000000000" = [
      {
        name = "profile"
        id   = "14dad69e-099b-42c9-810b-d002981feec1"
        type = "Scope"
      },
      {
        name = " User.Read"
        id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
        type = "Scope"
      },
      {
        name = "openid"
        id   = "37f7f235-527c-4136-accd-4a02d197296e"
        type = "Scope"
      },
      {
        name = "email"
        id   = "64a6cdd6-aab1-4aaf-94b8-3cc8405e90d0"
        type = "Scope"
      },
      {
        name = "TeamsAppInstallation.ReadWriteForChat"
        id   = "aa85bf13-d771-4d5d-a9e6-bca04ce44edf"
        type = "Scope"
      },
      {
        name = "TeamsTab.ReadWriteForChat"
        id   = "ee928332-e9c2-4747-b4a0-f8c164b68de6"
        type = "Scope"
      },
      {
        name = "Calendars.Read"
        id   = "465a38f9-76ea-45b9-9f34-9e8b0d4b0b42"
        type = "Scope"
      },
      {
        name = "Chat.Read"
        id   = "f501c180-9344-439a-bca0-6cbf209fd270"
        type = "Scope"
      },
      {
        name = "Contacts.Read"
        id   = "ff74d97f-43af-4b68-9f2a-b77ee6968c5d"
        type = "Scope"
      },
      {
        name = "offline_access"
        id   = "7427e0e9-2fba-42fe-b0c0-848c9e6a8182"
        type = "Scope"
      },
      {
        name = "OnlineMeetings.ReadWrite"
        id   = "a65f2972-a4f8-4f5e-afd7-69ccb046d5dc"
        type = "Scope"
      }
    ],
  }
}
variable "optional_claims" {
  type = any
  default = {
    access_token = {
      additional_properties = []
      essential             = false
      name                  = "groups"
    }
    id_token = {
      additional_properties = []
      essential             = false
      name                  = "groups"
    }
    saml2_token = {
      additional_properties = []
      essential             = false
      name                  = "groups"
    }
  }
}