#  Storage Account

This Terraform code defines the infrastructure for a Storage Account in Azure. It uses Azure resources to create a secure and reliable environment for storing and managing data.

## Breakdown of the Code

1. **Storage Account:**
   - Creates an Azure Storage Account with the specified name, location, resource group, account tier, account replication type, minimum TLS version, and HTTPS traffic only setting.
   - Sets the tags for the Storage Account using the `module.context.tags` variable.
   - Defines a lifecycle rule to ignore changes to the `customer_managed_key` attribute.

2. **Blob Properties:**
   - Defines a dynamic block named `cors_rule` to configure Cross-Origin Resource Sharing (CORS) rules for the Storage Account.
   - The block iterates over the `var.storage_account_cors_rules` variable and creates a CORS rule for each entry.
   - Each CORS rule defines the allowed origins, methods, headers, exposed headers, and maximum age in seconds.

3. **Storage Management Policy:**
   - Creates an Azure Storage Management Policy to automatically delete blobs older than a specified number of days.
   - The policy is only created if the `var.retention_period_days` variable is greater than 0.
   - The policy defines a rule named `delete-older-than-${var.retention_period_days}-days` that applies to block blobs.
   - The rule deletes blobs and snapshots older than the specified number of days and versions older than the specified number of days.

4. **Key Vault Secrets:**
   - Creates two Key Vault secrets to store the Storage Account connection strings:
     - `storage-account-connection-string-1`: Stores the primary connection string.
     - `storage-account-connection-string-2`: Stores the secondary connection string.
   - Sets the Key Vault ID for each secret.

5. **Key Vault Key:**
   - Creates an RSA-HSM key in the Key Vault for encrypting the Storage Account keys.
   - Sets the key size to the desired value.
   - Enables various key operations like decrypt, encrypt, sign, unwrapKey, verify, and wrapKey.

6. **Storage Account Customer-Managed Key:**
   - Configures the Storage Account to use the Key Vault key for encryption.
   - Sets the Key Vault ID, key name, and depends on the Key Vault key and a role assignment resource.

7. **Role Assignments:**
   - Grants the Storage Account access to the Key Vault for key decryption.
   - Grants the service principal used for SDK deployment access to the Storage Account.
   - Grants specified users access to the Key Vault secrets.



## Conclusion

This Terraform code demonstrates how to use Azure Storage Accounts to store and manage data in a highly performant and scalable manner. By leveraging Key Vaults, Storage Management Policies, and Customer-Managed Keys, the code ensures secure access, data lifecycle management, and encryption.

<br/><br/><hr/><br/><a href="https://eu1.hubs.ly/H09t3Sg0" target="_blank"><img src="https://www.unique.ch/hubfs/Badge%20Unique%20(1).svg" height="54"></a>