# Document Intelligence

This Terraform code defines the infrastructure for deploying an Azure Cognitive Service for Form Recognizer. It uses Azure resources to create a secure and reliable environment for processing forms and extracting data.

## Example

This example assumes that you already leverage other modules from Unique, namely `context` and `az-workload-identity`.

```hcl
module "document-ingelligence" {
  source           = "./az-document-intelligence"
  context          = module.context
  account_location = "westeurope"

  user_assigned_identity_ids = [
    module.workload_identities.user_assigned_identity_ids["node-ingestion-worker"],
  ]
}
```

## Breakdown of the Code

1. **Context Variables:**
   - Defines a variable named `context` to hold various configuration settings.
   - Sets default values for the namespace, project, environment, name, and tags.
   - Defines additional variables for the resource group and user-assigned identities.

2. **Context Module:**
   - Includes a module named `context` that generates context-specific values based on the provided variables.
   - This module calculates the full name of the resource based on the namespace, project, environment, and name.
   - It also merges the provided tags with a unique module tag.

3. **Random Pet Resource:**
   - Creates a random pet resource to generate a unique identifier.
   - This identifier is used to create unique names for the Cognitive Service account and custom subdomain.

4. **Local Variables:**
   - Defines local variables for the account name and custom subdomain name.
   - These variables use the generated identifier from the random pet resource to ensure uniqueness.

5. **Azure Cognitive Service Account:**
   - Creates an Azure Cognitive Service account for Form Recognizer.
   - Sets the name, location, resource group, kind, custom subdomain name, and SKU.
   - Adds the provided tags and configures user-assigned identities if specified.


## Conclusion

This Terraform code demonstrates how to use Azure Cognitive Services to process forms and extract data. By leveraging the Form Recognizer service, the code enables automated document processing and data extraction, improving efficiency and accuracy.

<br/><br/><hr/><br/><a href="https://eu1.hubs.ly/H09t3Sg0" target="_blank"><img src="https://www.unique.ch/hubfs/Badge%20Unique%20(1).svg" height="54"></a>