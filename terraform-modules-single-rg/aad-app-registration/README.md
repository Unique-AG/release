
#  Azure AD Application

This Terraform module defines an Azure Active Directory (Azure AD) application using the `azuread_application` resource. Let's break down the code step by step:

## Resource Definition

```hcl
resource "azuread_application" "this" {
```
This line defines a resource block for an Azure AD application named "this".

## Application Properties

- **display_name**: Sets the display name of the application. It uses a template with module context variables to dynamically generate a unique name based on the project and environment.
- **sign_in_audience**: Specifies the audience for sign-in. In this case, it's set to "AzureADMultipleOrgs", allowing users from multiple organizations to sign in.
- **privacy_statement_url**: Provides the URL for the application's privacy statement.
- **terms_of_service_url**: Provides the URL for the application's terms of service.
- **owners**: Assigns ownership of the application to specific users identified by their object IDs stored in the `var.owner_user_object_ids` variable.

## Web App Configuration

- **web**: Configures the web app properties of the application.
  - **homepage_url**: Sets the homepage URL of the application.
  - **implicit_grant**: Enables implicit grant flow for access tokens and ID tokens.
  - **redirect_uris**: Specifies the redirect URIs for the application. These are retrieved from the `var.redirect_uris` variable.

## Public Client Configuration

- **public_client**: Configures the public client properties of the application.
  - **redirect_uris**: Specifies the redirect URIs for the public client. These are retrieved from the `var.redirect_uris_public_native` variable.

## Required Resource Access

- **required_resource_access**: Defines the required resource access for the application.
  - **resource_app_id**: Specifies the resource application ID for which access is required.
  - **resource_access**: Defines the specific scopes required for accessing the resource.

## Dynamic Required Resource Access

```hcl
dynamic "required_resource_access" {
  for_each = var.use_intune ? [1] : []
  content {
    resource_app_id = "0000000a-0000-0000-c000-000000000000" # Example ID for Intune
    resource_access {
      id   = "0000000a-0000-0000-c000-000000000000"
      type = "Scope"
    }
  }
}
```
This block defines a dynamic block for the `required_resource_access` attribute.

- **for_each**: Specifies the condition for creating the dynamic block. In this case, it's created only if the `var.use_intune` variable is set to true.
- **content**: Defines the content of the dynamic block, including the resource application ID and required scopes.
