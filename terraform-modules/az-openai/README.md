# Azure OpenAI service

This Terraform code defines the infrastructure for deploying an Azure OpenAI service. It uses Azure resources to create a secure and reliable environment for accessing and using OpenAI models.

## Breakdown of the Code

1. **Random Pet Resource:**
   - Creates a `random_pet` resource to generate a unique identifier.
   - This identifier is used to create unique names for the Cognitive Service account and custom subdomain.

2. **Local Variables:**
   - Defines local variables for the account name and custom subdomain name.
   - These variables use the generated identifier from the `random_pet` resource to ensure uniqueness.
   - They also use the `coalesce` function to set default values if not provided in the variables.

3. **Azure Cognitive Service Account:**
   - Creates an Azure Cognitive Service account for OpenAI.
   - Sets the name, location, resource group, kind, custom subdomain name, and SKU.
   - Adds the provided tags and configures user-assigned identities if specified.

4. **Key Vault Secrets:**
   - Creates two Key Vault secrets if a Key Vault ID is provided:
     - `key`: Stores the primary access key for the Cognitive Service account.
     - `endpoint`: Stores the endpoint URL for the Cognitive Service account.

5. **Azure OpenAI Deployments:**
   - Creates deployments for the specified OpenAI models.
   - Each deployment defines the model name, version, RAI policy name, and scaling configuration.
   - The code uses a `for_each` loop to iterate over the provided deployments configuration.


## Conclusion

This Terraform code demonstrates how to use Azure OpenAI to access and use OpenAI models. By leveraging the OpenAI service, the code enables developers to integrate powerful language models into their applications.
