# Key-vaults

This Terraform code defines the infrastructure for a Key Vault in Azure. It uses Azure resources to create a secure and reliable environment for storing secrets.

## Breakdown of the Code

1. **Key Vault:**
   - Creates a Key Vault to store secrets securely.
   - Enables disk encryption and soft delete protection for added security.
   - Sets the SKU to "standard" for basic features and performance.
   - Defines tags for organization and management.

2. **Role Assignments:**
   - Grants users access to the Key Vault secrets based on the provided list of principal IDs.

3. **Key Vault Secrets:**
   - Creates several secrets in the Key Vault:
     - `rabbitmq-username`: Stores the username for the RabbitMQ service.
     - `rabbitmq-password`: Stores the password for the RabbitMQ service.
     - `rabbitmq-erlang-cookie`: Stores the Erlang cookie for the RabbitMQ service.
     - `zitadel-main-key`: Stores the main key for the Zitadel service.
     - `zitadel-zitadel-password`: Stores the password for the Zitadel service.
     - `tyk-api-secret`: Stores the API secret for the Tyk service.
     - `placeholders`: Creates secrets with placeholder values for manual configuration later.

4. **Random Password Generation:**
   - Uses the `random_password` resource to generate secure passwords for the RabbitMQ and Zitadel services.

5. **Lifecycle Management:**
   - Defines a lifecycle rule for the `placeholders` secret to ignore changes to the value and tags, allowing manual configuration without triggering Terraform updates.



## Conclusion

This Terraform code demonstrates how to use Azure Key Vault to securely store and manage secrets for an application. By leveraging Key Vault features like role-based access control and lifecycle management, the code ensures secure access and protection of sensitive information.
