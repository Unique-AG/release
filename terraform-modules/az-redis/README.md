#  Redis Cache

This Terraform code defines the infrastructure for deploying a Redis Cache in Azure. It uses Azure resources to create a secure and reliable environment for storing and managing data in a cache.

## Breakdown of the Code

1. **Redis Cache:**
   - Creates an Azure Redis Cache instance with the specified name, location, resource group, capacity, family, SKU, minimum TLS version, public network access, and Redis version.
   - Sets the tags for the Redis Cache using the `local.tags` variable.

2. **Network Security Group:**
   - Creates an Azure Network Security Group (NSG) with the specified name, location, and resource group.
   - Defines two security rules:
     - `AllowToRedis`: Allows inbound traffic from the specified subnet on ports 6379-6380 (Redis ports).
     - `DenyAll`: Denies all other inbound traffic.
   - Sets the tags for the NSG using the `local.tags` variable.

3. **Subnet Network Security Group Association:**
   - Associates the Redis Cache subnet with the created NSG. This ensures that only authorized traffic can access the Redis Cache.

4. **Key Vault Secrets:**
   - Creates three Key Vault secrets to store the Redis Cache password, host DNS name, and port:
     - `redis-cache-password`: Stores the primary access key for the Redis Cache.
     - `redis-cache-host-dns`: Stores the hostname of the Redis Cache.
     - `redis-cache-port`: Stores the SSL port of the Redis Cache.
   - Sets the Key Vault ID for each secret.


## Conclusion

This Terraform code demonstrates how to use Azure Redis Cache to store and manage data in a highly performant and scalable manner. By leveraging NSGs and Key Vault, the code ensures secure access and protection of sensitive information.

<br/><br/><hr/><br/><a href="https://eu1.hubs.ly/H09t3Sg0" target="_blank"><img src="https://www.unique.ch/hubfs/Badge%20Unique%20(1).svg" height="54"></a>