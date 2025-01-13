# Azure Security Center

This Terraform code configures Azure Security Center for a subscription, enabling various security features and settings. Let's break down the code section by section:

## Breakdown of the Code

1. **Security Center Subscription Pricing:**
   - This section defines several resources of type `azurerm_security_center_subscription_pricing`. These resources enable different security features based on the chosen tier and resource type.
     - The `cspm_free` resource enables the free tier of Cloud Posture Management (CSPM), which provides basic security posture assessment for cloud resources.
     - The `cspm_full` resource enables the standard tier of CSPM, which provides additional features like vulnerability assessments, agentless VM scanning, and sensitive data discovery.
     - The `cwp_storage`, `cwp_servers`, `cwp_keyvaults`, and `cwp_resourcemanager` resources enable the standard tier of Cloud Workload Protection (CWP) for different resource types: Storage Accounts, Virtual Machines, Key Vaults, and Azure Resource Manager.

3. **Security Center Contact:**
   - This section defines a resource of type `azurerm_security_center_contact`. This resource creates a security contact with the specified email address. This contact will receive notifications about security alerts and incidents.

4. **Security Center Subscription Pricing for CWP Storage:**
   - This section defines a resource of type `azurerm_security_center_subscription_pricing` specifically for CWP Storage. It enables the standard tier with the "DefenderForStorageV2" subplan, which provides features like on-upload malware scanning and sensitive data discovery.

5. **Security Center Subscription Pricing for CWP Servers:**
   - This section defines a resource of type `azurerm_security_center_subscription_pricing` specifically for CWP Servers. It enables the standard tier with the "P2" subplan, which provides features like agentless VM scanning.

6. **Security Center Subscription Pricing for CWP Key Vaults:**
   - This section defines a resource of type `azurerm_security_center_subscription_pricing` specifically for CWP Key Vaults. It enables the standard tier with the "PerKeyVault" subplan, which provides security features for Key Vaults.

7. **Security Center Subscription Pricing for CWP Resource Manager:**
   - This section defines a resource of type `azurerm_security_center_subscription_pricing` specifically for CWP Resource Manager. It enables the standard tier with the "PerSubscription" subplan, which provides security features for Azure Resource Manager resources.


## Conclusion

This Terraform code demonstrates how to use Azure Security Center to enhance the security posture of a subscription. By enabling various features and settings, the code helps protect resources from threats and vulnerabilities while providing visibility into security events and incidents.
