resource "azuread_application" "this" {
  display_name          = "[${module.context.project}-${module.context.environment}] Unique AG"
  sign_in_audience      = "AzureADMultipleOrgs"
  privacy_statement_url = "https://www.unique.ch/privacy"
  terms_of_service_url  = "https://www.unique.ch/terms"
  owners                = var.owner_user_object_ids
  web {
    homepage_url = "https://www.unique.ch"
    implicit_grant {
      access_token_issuance_enabled = true
      id_token_issuance_enabled     = true
    }
    redirect_uris = var.redirect_uris
  }
  public_client {
    redirect_uris = var.redirect_uris_public_native
  }
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000"
    resource_access {
      id   = "14dad69e-099b-42c9-810b-d002981feec1"
      type = "Scope"
    }
    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
      type = "Scope"
    }
    resource_access {
      id   = "37f7f235-527c-4136-accd-4a02d197296e"
      type = "Scope"
    }
    resource_access {
      id   = "64a6cdd6-aab1-4aaf-94b8-3cc8405e90d0"
      type = "Scope"
    }
    resource_access {
      id   = "aa85bf13-d771-4d5d-a9e6-bca04ce44edf"
      type = "Scope"
    }
    resource_access {
      id   = "ee928332-e9c2-4747-b4a0-f8c164b68de6"
      type = "Scope"
    }
    resource_access {
      id   = "465a38f9-76ea-45b9-9f34-9e8b0d4b0b42"
      type = "Scope"
    }
    resource_access {
      id   = "f501c180-9344-439a-bca0-6cbf209fd270"
      type = "Scope"
    }
    resource_access {
      id   = "ff74d97f-43af-4b68-9f2a-b77ee6968c5d"
      type = "Scope"
    }
    resource_access {
      id   = "7427e0e9-2fba-42fe-b0c0-848c9e6a8182"
      type = "Scope"
    }
    resource_access {
      id   = "a65f2972-a4f8-4f5e-afd7-69ccb046d5dc"
      type = "Scope"
    }
  }
  optional_claims {
    access_token {
      additional_properties = []
      essential             = false
      name                  = "groups"
    }
    id_token {
      additional_properties = []
      essential             = false
      name                  = "groups"
    }
    saml2_token {
      additional_properties = []
      essential             = false
      name                  = "groups"
    }
  }
  dynamic "required_resource_access" {
    for_each = var.use_intune ? [1] : []
    content {
      resource_app_id = "0a5f63c0-b750-4f38-a71c-4fc0d58b89e2"
      resource_access {
        id   = "3c7192af-9629-4473-9276-d35e4e4b36c5"
        type = "Scope"
      }
    }
  }
}