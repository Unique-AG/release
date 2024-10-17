# AKS Cluster

This Terraform code defines the configuration for an Azure Kubernetes Service (AKS) cluster. Let's break down the code section by section:

## Breakdown of the Code

1. **Public IP:**
   - This section defines a public IP address for the cluster's load balancer.
   - The IP address is named after the cluster and is allocated statically.
   - It uses the standard SKU and is deployed across three availability zones for redundancy.

2. **AKS Cluster:**
   - This section defines the main AKS cluster configuration.
   - The cluster name is based on the module context.
   - It's deployed in the same location and resource group as the public IP.
   - The DNS prefix is set to the cluster name.
   - The cluster uses the standard tier and is configured for automatic upgrades on the stable channel.
   - Azure Policy is enabled for the cluster.
   - The desired Kubernetes version is specified by the `kubernetes_version` variable.
   - Local accounts are disabled, and OIDC issuer is enabled.
   - Workload identity is enabled for the cluster.
   - The cluster is configured as a private cluster with a private DNS zone.
   - The private cluster's public FQDN is enabled.

3. **Network Profile:**
   - This section defines the network configuration for the cluster.
   - It uses the Azure network plugin and Azure network policy.
   - The load balancer profile specifies an idle timeout of 100 minutes and uses the public IP defined earlier.

4. **Storage Profile:**
   - This section enables the blob driver and sets the disk driver version to `v1`.

5. **Azure Active Directory Role-Based Access Control:**
   - This section enables managed Azure RBAC for the cluster.

6. **Workload Autoscaler Profile:**
   - This section enables the KEDA autoscaler and disables the vertical pod autoscaler.

7. **Maintenance Window:**
   - This section defines the allowed maintenance window for the cluster.
   - The maintenance is scheduled on the specified day and within the specified hour range.

8. **Auto-Scaler Profile:**
   - This section configures the cluster's auto-scaler.
   - It sets the maximum graceful termination time, disables skipping nodes with local storage, and defines the expander, scale-down behavior, and utilization threshold.

9. **Default Node Pool:**
   - This section defines the default node pool for the cluster.
   - The pool is named "default" and has a temporary name for rotation.
   - The node size, auto-scaling, minimum and maximum node count, OS disk size, pod and node subnets, and availability zones are specified.
   - The pool uses Virtual Machine Scale Sets and inherits tags from the module context.
   - Upgrade settings are configured to allow a maximum surge of one node during upgrades.

10. **Identity:**
    - This section enables system-assigned managed identity for the cluster.

11. **OMS Agent:**
    - This section configures the OMS agent for the cluster.
    - It specifies the Log Analytics workspace ID and enables MSI authentication for monitoring.

12. **Microsoft Defender:**
    - This section enables Microsoft Defender for the cluster and specifies the Log Analytics workspace ID.

13. **Key Vault Secrets Provider:**
    - This section enables the Key Vault secrets provider for the cluster and enables secret rotation.

14. **Ingress Application Gateway:**
    - This section configures the cluster to use an existing Application Gateway for ingress.
    - The gateway ID is specified.

15. **Monitor Metrics:**
    - This section dynamically creates a `monitor_metrics` block if the `azure_prometheus_grafana_monitor.enabled` variable is set to true.

16. **Tags:**
    - This section inherits tags from the module context.

17. **Lifecycle:**
    - This section ignores changes to the `kubernetes_version` attribute.



## Conclusion

This Terraform code provides a comprehensive configuration for an AKS cluster with various features and settings. It demonstrates how Terraform can be used to manage and automate the deployment and configuration of AKS clusters in a declarative way.

<br/><br/><hr/><br/><a href="https://eu1.hubs.ly/H09t3Sg0" target="_blank"><img src="https://www.unique.ch/hubfs/Badge%20Unique%20(1).svg" height="54"></a>