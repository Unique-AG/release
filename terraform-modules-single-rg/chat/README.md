
# Chat

This Terraform code defines the infrastructure for deploying Chat service. It uses Azure resources to create a secure and reliable environment for accessing and using OpenAI models and storing logs.

## Breakdown of the Code

1. **Module "openai":**
   - This module defines the infrastructure for deploying an Azure OpenAI service.
   - It uses the `az-openai` module to configure the service with the specified name, location, key vault ID, and deployments.
   - The deployments section defines the OpenAI models to be deployed, including their names, model names, model versions, SKU names, and SKU capacities.
   - The `user_assigned_identity_ids` variable is used to specify the user-assigned identities that will be used to access the OpenAI service.

2. **Module "app-repository-logs":**
   - This module defines the infrastructure for storing and managing logs for the App Repository.
   - It uses the `app-repository-logs` module to configure the service with the specified context, workload identity, logs destination Azure subscription ID, logs destination Azure resource group name, key vault access principals, storage account key list operator service role ID, and SDK deployment service principal object IDs.
   - The `workload_identity` section defines the AKS OIDC issuer URL that will be used to authenticate the workload identity.
   - The `logs_destination_azure_subscription_id` and `logs_destination_azure_resource_group_name` variables are used to specify the Azure subscription and resource group where the logs will be stored.
   - The `keyvault_access_principals` variable is used to specify the principals that will have access to the key vault where the logs are stored.
   - The `storage_account_key_list_operator_service_role_id` variable is used to specify the service role ID that allows listing keys in the storage account where the logs are stored.
   - The `sdk_deployment_service_principal_object_ids` variable is used to specify the service principal object IDs that will be used to access the storage account where the logs are stored.

3. **Resource "azurerm_role_assignment":**
   - This resource defines two role assignments for the Key Vault.
   - The first role assignment grants the "Key Vault Secrets User" and "Key Vault Crypto User" roles to the principal ID of the Storage Account.
   - The second role assignment grants the "Key Vault Secrets User" role to each of the principals specified in the `keyvault_access_principals` variable.

4. **Data "azurerm_storage_account":**
   - This data source retrieves information about the Storage Account.
   - It is used to retrieve the Storage Account ID, which is used in the `azurerm_key_vault_secret` resources.

5. **Resource "azurerm_key_vault":**
   - This resource defines the Key Vault.
   - It is configured with the specified name, location, resource group name, enabled for disk encryption, tenant ID, soft delete retention days, purge protection enabled, enable RBAC authorization, SKU name, and tags.

6. **Locals:**
   - This section defines local variables that are used throughout the code.
   - The `all_model_endpoints` variable combines the Azure OpenAI endpoints and the App Repository Logs endpoints.
   - The `all_model_names` variable extracts the distinct model names from the `all_model_endpoints` variable.
   - The `merged_model_endpoints` variable creates a map of model names to their corresponding endpoints.

7. **Resource "azurerm_key_vault_secret":**
   - This resource defines the following Key Vault secrets.
   - The JSON-encoded `merged_model_endpoints` variable.
   - The JSON-encoded `azure_document_intelligence_endpoints` variable.
   - The JSON-encoded `azure_document_intelligence_endpoint_definitions` variable.

8. **Resource "azurerm_postgresql_flexible_server_database":**
   - This resource defines the PostgreSQL databases for the App Repository.
   - It uses a `for_each` loop to create a database for each of the values in the `dbs` local variable.

9. **Resource "azurerm_storage_account":**
   - This resource defines the Storage Account for the App Repository Logs.
   - It is configured with the specified name, location, resource group name, account tier, account replication type, allow nested items to be public, minimum TLS version, enable HTTPS traffic only, tags, and blob properties.
   - The `blob_properties` section defines the CORS rules for the Storage Account.

10. **Resource "azurerm_key_vault_secret":**
    - This resource defines two Key Vault secrets that store the Storage Account connection strings.

11. **Resource "azurerm_key_vault_key":**
    - This resource defines the Key Vault key that will be used to encrypt the Storage Account keys.

12. **Resource "azurerm_storage_account_customer_managed_key":**
    - This resource configures the Storage Account to use the Key Vault key for encryption.


## Conclusion

This Terraform code demonstrates how to use Azure OpenAI and App Repository Logs to enhance the capabilities of an application. By leveraging these services, the code enables access to powerful language models and provides a secure and reliable way to store and manage logs.

<br/><br/><hr/><br/><a href="https://eu1.hubs.ly/H09t3Sg0" target="_blank"><img src="https://www.unique.ch/hubfs/Badge%20Unique%20(1).svg" height="54"></a>