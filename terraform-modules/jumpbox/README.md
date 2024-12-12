# Jumpbox

This Terraform code defines the configuration for a jumpbox in Azure. Let's break down the code section by section:

## Breakdown of the Code

1. **Locals:**
   - This section defines a local variable `cloud_init_scripts_version` which is used to specify the version of the cloud-init scripts to be used.

2. **TLS Private Key:**
   - This section generates a TLS private key using the `tls_private_key` resource. This key will be used for SSH access to the jumpbox.

3. **Virtual Machine Module:**
   - This section defines the main jumpbox configuration using the `azurerm/virtual-machine` module.
   - The module is configured with the following settings:
     - **Name:** Based on the module context's full name.
     - **Resource group:** Based on the module context's resource group.
     - **Location:** Based on the module context's resource group location.
     - **Image:** Ubuntu Server 22.04 LTS (Gen2).
     - **Size:** Specified by the `jumpbox_size` variable.
     - **Subnet:** Based on the `jumpbox_subnet` variable.
     - **Allow extension operations:** Enabled.
     - **Password authentication:** Disabled.
     - **Admin username:** `azureuser`.
     - **Patch assessment mode:** Automatic by platform.
     - **Admin SSH keys:** Public key generated in the previous step.
     - **OS disk:** Caching set to `ReadWrite` and storage account type set to `StandardSSD_LRS`.
     - **Network interface:** IP forwarding disabled and primary configuration set.
     - **Identity:** System-assigned managed identity.
     - **Extensions:**
       - `AADSSHLoginForLinux`: Enables SSH access using Azure Active Directory.
       - `AzureMonitorLinuxAgent`: Enables Azure Monitor for Linux.
     - **Custom data:** Base64 encoded content of all `.sh` files in the cloud-init-scripts directory.
     - **Tags:** Inherited from the module context.

4. **Public IP:**
   - This section defines a public IP address for the jumpbox using the `azurerm_public_ip` resource.
   - The IP address is named after the jumpbox and is allocated statically.
   - It uses the Standard SKU and is deployed in the same location and resource group as the jumpbox.

5. **Bastion Host:**
   - This section defines a bastion host using the `azurerm_bastion_host` resource.
   - The bastion host is named after the jumpbox and is deployed in the same location and resource group.
   - It uses the Standard SKU and has tunneling enabled.
   - The IP configuration specifies the jumpbox's public IP address and subnet.

6. **VM Shutdown Schedule:**
   - This section defines a VM shutdown schedule using the `azurerm_dev_test_global_vm_shutdown_schedule` resource.
   - The schedule is enabled and set to shut down the jumpbox daily at 21:00 W. Europe Standard Time.
   - Notifications are disabled.

7. **Data Collection Rule:**
   - This section defines a data collection rule using the `azurerm_monitor_data_collection_rule` resource.
   - The rule is named after the jumpbox and is deployed in the same location and resource group.
   - It collects Syslog data from the jumpbox and sends it to the specified Log Analytics workspace.

8. **Data Collection Rule Association:**
   - This section associates the data collection rule with the jumpbox using the `azurerm_monitor_data_collection_rule_association` resource.


## Conclusion

This Terraform code provides a comprehensive configuration for a jumpbox in Azure, including SSH access, security, monitoring, and automated shutdown. It demonstrates how Terraform can be used to manage and automate the deployment and configuration of jumpboxes in a declarative way.

<br/><br/><hr/><br/><a href="https://eu1.hubs.ly/H09t3Sg0" target="_blank"><img src="https://www.unique.ch/hubfs/Badge%20Unique%20(1).svg" height="54"></a>