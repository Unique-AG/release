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
  dynamic "required_resource_access" {
    for_each = [for resource_app_id, accesses in var.required_resource_access_list : {
      resource_app_id = resource_app_id
      accesses        = accesses
    }]
    content {
      resource_app_id = required_resource_access.value.resource_app_id
      dynamic "resource_access" {
        for_each = required_resource_access.value.accesses
        content {
          id   = resource_access.value.id
          type = resource_access.value.type
        }
      }
    }
  }
  dynamic "optional_claims" {
    for_each = var.optional_claims != null ? ["true"] : []
    content {
      dynamic "access_token" {
        for_each = var.optional_claims.access_token != null ? [var.optional_claims.access_token] : []
        content {
          additional_properties = lookup(var.optional_claims.access_token, "additional_properties", [])
          essential             = lookup(var.optional_claims.access_token, "essential", null)
          name                  = lookup(var.optional_claims.access_token, "name", [])
          source                = lookup(var.optional_claims.access_token, "source", null)
        }
      }
      dynamic "id_token" {
        for_each = var.optional_claims.id_token != null ? [var.optional_claims.id_token] : []
        content {
          additional_properties = lookup(var.optional_claims.id_token, "additional_properties", null)
          essential             = lookup(var.optional_claims.id_token, "essential", null)
          name                  = lookup(var.optional_claims.id_token, "name", null)
          source                = lookup(var.optional_claims.id_token, "source", null)
        }
      }
      dynamic "saml2_token" {
        for_each = var.optional_claims.saml2_token != null ? [var.optional_claims.saml2_token] : []
        content {
          additional_properties = lookup(var.optional_claims.saml2_token, "additional_properties", null)
          essential             = lookup(var.optional_claims.saml2_token, "essential", null)
          name                  = lookup(var.optional_claims.saml2_token, "name", null)
          source                = lookup(var.optional_claims.saml2_token, "source", null)
        }
      }
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