# Azure Infrastructure Deployment with Terraform

This project defines and manages various Azure resources using Terraform, providing a comprehensive and automated way to deploy and configure infrastructure. The resources include Azure Cognitive Services, Azure OpenAI service, App Repository Logs module, Azure Kubernetes Service (AKS) cluster, PostgreSQL Flexible Server, jumpbox, and Virtual Network (VNET). Each module is designed to be flexible, secure, and customizable to meet different deployment requirements.

## Summary of Modules

### 1. Azure Cognitive Service for Form Recognizer
This module defines the infrastructure for deploying an Azure Cognitive Service for Form Recognizer. It includes:
- Random pet resource for unique naming.
- Local variables for account and subdomain names.
- Cognitive Service account setup.
- Key Vault secrets for storing keys and endpoints.
- Model deployments.

### 2. Azure OpenAI Service and App Repository Logs
This module provides infrastructure for deploying an Azure OpenAI service and managing logs for the App Repository. Key features include:
- OpenAI service setup with specific deployments.
- App Repository Logs configuration including workload identity, storage, and key vault management.
- Role assignments and monitoring setup.

### 3. Azure Kubernetes Service (AKS) Cluster
This module defines the configuration for an AKS cluster with comprehensive settings:
- Public IP setup for load balancer.
- AKS cluster configuration including networking, storage, and identity management.
- Autoscaler and maintenance window configurations.
- Extensions for monitoring and security.

### 4. PostgreSQL Flexible Server
This module configures a PostgreSQL Flexible Server with secure networking and key management:
- User-assigned identity creation.
- Private DNS zone and virtual network link setup.
- Key Vault integration for encryption and password management.
- Server configuration and monitoring setup.

### 5. Jumpbox
This module sets up a jumpbox for secure access to the Azure environment:
- TLS private key generation.
- VM setup with Azure Monitor and AAD integration.
- Public IP and Bastion Host setup for secure access.
- Scheduled shutdown and monitoring configurations.

### 6. Virtual Network (VNET)
This module creates a Virtual Network and manages subnets, peerings, and delegations:
- VNET and subnet creation.
- Dynamic configuration for subnet CIDR blocks and peerings.
- Delegation and service endpoint support.
- Efficient subnet allocation and management.

## Key Features and Benefits

- **Security**: Modules include comprehensive security measures such as private networking, key vault integrations, and managed identities.
- **Automation**: Automated deployment and configuration of resources using Terraform.
- **Flexibility**: Highly customizable modules with variables for different settings and configurations.
- **Scalability**: Supports scaling operations for resources like AKS clusters and PostgreSQL servers.
- **Monitoring**: Integrated monitoring and logging setups for enhanced visibility and management.

## Conclusion

This Terraform project provides a robust framework for deploying and managing Azure resources in a secure, automated, and scalable manner. By leveraging Terraform's declarative approach, it ensures consistency and repeatability in infrastructure management, making it an ideal solution for complex cloud environments.

## Additional Notes

- Variables and configurations can be adjusted based on specific requirements.
- Detailed explanations within the modules provide further guidance on usage and customization.

<br/><br/><hr/><br/><a href="https://eu1.hubs.ly/H09t3Sg0" target="_blank"><img src="https://www.unique.ch/hubfs/Badge%20Unique%20(1).svg" height="54"></a>
