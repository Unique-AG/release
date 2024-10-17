# Workload Identities

This Terraform code defines the infrastructure for creating and managing workload identities in Azure. It uses Azure resources to create a secure and reliable environment for accessing Azure services with managed identities.

## Breakdown of the Code

1. **Local Variables:**
   - Defines a local variable named `workload_roles` using the `distinct` and `flatten` functions.
   - This variable extracts unique role definitions from the `var.identities` variable, which contains a map of service names to identity configurations.

2. **User-Assigned Identities:**
   - Creates a `for_each` loop that iterates over the `var.identities` variable.
   - For each service in the variable, creates a User-Assigned Identity with a unique name based on the module context and service name.
   - Sets the location and resource group name for the identity based on the module context.

3. **Role Assignments:**
   - Creates a `for_each` loop that iterates over the `local.workload_roles` variable.
   - For each role definition, creates a Role Assignment with the specified scope, role definition name, and principal ID.
   - The scope is set to the ID of the management group retrieved from the `data.azurerm_management_group` data source.
   - The role definition name is taken from the `local.workload_roles` variable.
   - The principal ID is set to the `principal_id` attribute of the User-Assigned Identity for the corresponding service.

4. **Federated Identity Credentials:**
   - Creates a `for_each` loop that iterates over the `var.identities` variable.
   - For each service in the variable, creates a Federated Identity Credential with a unique name based on the module context and service name.
   - Sets the resource group name, audience, issuer, parent ID, and subject for the credential.
     - The audience is set to the Azure AD Token Exchange endpoint.
     - The issuer is set to the `var.aks_oidc_issuer_url` variable, which contains the OIDC issuer URL for the AKS cluster.
     - The parent ID is set to the ID of the User-Assigned Identity for the corresponding service.
     - The subject is set to a format that includes the system, service account, namespace, and service name.

5. **Key Vault Secrets:**
   - Creates a `for_each` loop that iterates over the `var.identities` variable.
   - For each service in the variable, creates a Key Vault Secret with a unique name based on the service name.
   - Sets the value of the secret to the `client_id` attribute of the User-Assigned Identity for the corresponding service.
   - Sets the Key Vault ID for the secret based on the `keyvault_id` attribute in the identity configuration for the service.


## Conclusion

This Terraform code demonstrates how to use Azure Workload Identities to provide secure access to Azure services without managing credentials directly. By leveraging User-Assigned Identities, Role Assignments, Federated Identity Credentials, and Key Vault Secrets, the code ensures secure access and management of identities for various services.

<br/><br/><hr/><br/><a href="https://eu1.hubs.ly/H09t3Sg0" target="_blank"><img src="https://www.unique.ch/hubfs/Badge%20Unique%20(1).svg" height="54"></a>