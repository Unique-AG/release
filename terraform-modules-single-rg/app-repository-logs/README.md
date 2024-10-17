# App Repository Logs
This Terraform code defines the infrastructure for storing and managing logs for an application. It uses Azure resources to create a secure and reliable environment for log storage.

## Breakdown of the Code

1. **Key Vault:**
   - Creates a Key Vault to store secrets securely.
   - Enables disk encryption and soft delete protection for added security.
   - Sets the SKU to "premium" for enhanced performance and features.

2. **Storage Account:**
   - Creates a Storage Account to store the logs.
   - Configures the account for LRS (Locally Redundant Storage) replication.
   - Enables HTTPS traffic only for secure communication.
   - Defines a lifecycle rule to automatically delete logs older than a specified number of days.

3. **Key Vault Key:**
   - Creates an RSA-HSM key in the Key Vault for encrypting the Storage Account keys.
   - Sets the key size to the desired value.

4. **Role Assignments:**
   - Grants the Storage Account access to the Key Vault for key decryption.
   - Grants the service principal used for SDK deployment access to the Storage Account.
   - Grants specified users access to the Key Vault secrets.

5. **Customer-Managed Key:**
   - Configures the Storage Account to use the Key Vault key for encryption.

6. **Key Vault Secrets:**
   - Stores the Storage Account's blob endpoint and Azure subscription ID as secrets in the Key Vault.
   - Stores the Azure resource group name for the logs destination as a secret.

7. **User-Assigned Identity:**
   - Creates a User-Assigned Identity for accessing the Storage Account.

8. **Role Assignment for User-Assigned Identity:**
   - Grants the User-Assigned Identity the "Blob Data Reader" role on the Storage Account.

9. **Federated Identity Credential:**
   - Creates a Federated Identity Credential to allow the User-Assigned Identity to authenticate with Azure AD.
   - Sets the audience to the Azure AD Token Exchange endpoint.
   - Sets the issuer to the AKS OIDC issuer URL.
   - Sets the parent ID to the User-Assigned Identity ID.
   - Sets the subject to the service account information.

10. **Key Vault Secret for Client ID:**
    - Stores the User-Assigned Identity's client ID as a secret in the Key Vault.


## Conclusion

This Terraform code demonstrates how to use Azure resources to build a secure and reliable log storage solution for an application. By leveraging Key Vaults, Storage Accounts, and User-Assigned Identities, the code ensures secure access and management of logs while automating the lifecycle management process.

<br/><br/><hr/><br/><a href="https://eu1.hubs.ly/H09t3Sg0" target="_blank"><img src="https://www.unique.ch/hubfs/Badge%20Unique%20(1).svg" height="54"></a>