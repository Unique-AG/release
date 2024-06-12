# Azure Monitor Action Group

This Terraform code defines an Azure Monitor Action Group named "p0". Action Groups are used to group recipients and define actions to be taken when an alert is triggered.

## Breakdown of the Code

1. **Resource Definition:**
   - The code defines a resource of type `azurerm_monitor_action_group`.
   - The resource name is set to `"p0-${module.context.full_name}"`. This uses the `module.context.full_name` variable to generate a unique name based on the context.
   - The resource group name is set to `module.context.resource_group.name`. This uses the `module.context.resource_group.name` variable to reference the resource group where the action group should be created.
   - The short name is set to `"p0${module.context.project}"`. This uses the `module.context.project` variable to generate a short name based on the project.

2. **Dynamic Email Receivers:**
   - The code defines a dynamic block named `email_receiver`. This block allows for the creation of multiple email receivers based on the values in the `var.p0_email_addresses` variable.
   - For each email address in the variable, the block creates an email receiver with a unique name based on the project and email address.
   - The `email_address` and `use_common_alert_schema` attributes are set based on the values in the `email_receiver.value` object.

3. **Tags:**
   - The code sets the tags for the action group using the `module.context.tags` variable. This allows for consistent tagging across resources.


## Conclusion

This Terraform code demonstrates how to use Azure Monitor Action Groups to define recipients and actions for alerts. By leveraging dynamic blocks and variables, the code enables the creation of customized action groups that meet specific requirements.
