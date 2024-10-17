locals {
  cloud_init_scripts_version = var.cloud_init_scripts_version != "" ? "-${var.cloud_init_scripts_version}" : ""
}
resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}
module "virtual-machine" {
  source                          = "Azure/virtual-machine/azurerm"
  version                         = "1.0.0"
  name                            = module.context.full_name
  resource_group_name             = module.context.resource_group.name
  location                        = module.context.resource_group.location
  image_os                        = "linux"
  size                            = var.jumpbox_size
  subnet_id                       = var.jumpbox_subnet.id
  allow_extension_operations      = true
  disable_password_authentication = true
  admin_username                  = "azureuser"
  patch_assessment_mode           = "AutomaticByPlatform"
  patch_mode                      = "AutomaticByPlatform"
  source_image_reference = {
    offer     = "0001-com-ubuntu-server-jammy"
    publisher = "canonical"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  admin_ssh_keys = [
    {
      public_key = tls_private_key.this.public_key_openssh
    }
  ]
  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }
  new_network_interface = {
    ip_forwarding_enabled = false
    ip_configurations = [
      {
        primary = true
      }
    ]
  }
  identity = {
    type = "SystemAssigned"
  }
  extensions = [
    {
      name                        = "${module.context.full_name}-aadsshloginforlinux"
      publisher                   = "Microsoft.Azure.ActiveDirectory"
      type                        = "AADSSHLoginForLinux"
      type_handler_version        = "1.0"
      auto_upgrade_minor_version  = true
      failure_suppression_enabled = false
    },
    {
      name                       = "${module.context.full_name}-AzureMonitorLinuxAgent"
      publisher                  = "Microsoft.Azure.Monitor"
      type                       = "AzureMonitorLinuxAgent"
      type_handler_version       = "1.0"
      auto_upgrade_minor_version = true
    }
  ]
  custom_data = base64encode(join("\n", [for file in tolist(fileset(path.module, "cloud-init-scripts${local.cloud_init_scripts_version}/*.sh")) : file("${path.module}/${file}")]))
  tags        = module.context.tags
}
resource "azurerm_public_ip" "this" {
  name                = "${module.context.full_name}-bastion"
  location            = module.context.resource_group.location
  resource_group_name = module.context.resource_group.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
resource "azurerm_bastion_host" "this" {
  name                = module.context.full_name
  location            = module.context.resource_group.location
  resource_group_name = module.context.resource_group.name
  sku                 = "Standard"
  tunneling_enabled   = true
  ip_configuration {
    name                 = module.context.full_name
    subnet_id            = var.bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.this.id
  }
}
resource "azurerm_dev_test_global_vm_shutdown_schedule" "example" {
  virtual_machine_id    = module.virtual-machine.vm_id
  location              = module.context.resource_group.location
  enabled               = true
  daily_recurrence_time = "2100"
  timezone              = "W. Europe Standard Time"
  notification_settings {
    enabled = false
  }
}
resource "azurerm_monitor_data_collection_rule" "dcr" {
  name                = "${module.context.full_name}-dcr-linux"
  resource_group_name = module.context.resource_group.name
  location            = module.context.resource_group.location
  kind                = "Linux"
  destinations {
    log_analytics {
      workspace_resource_id = var.log_analytics_workspace_id
      name                  = "destination-log"
    }
  }
  data_flow {
    streams      = ["Microsoft-Syslog"]
    destinations = ["destination-log"]
  }
  data_sources {
    syslog {
      facility_names = ["local3", "local7"]
      log_levels     = ["Info", "Notice", "Warning", "Error", "Critical", "Alert", "Emergency"]
      name           = "datasource-syslog"
    }
  }
}
resource "azurerm_monitor_data_collection_rule_association" "dcr_vm_association" {
  name                    = "${module.context.full_name}-dcr-vm-association"
  target_resource_id      = module.virtual-machine.vm_id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.dcr.id
  description             = "Association between the Data Collection Rule and the Linux VM."
}