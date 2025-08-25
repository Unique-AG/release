resource "azapi_resource" "this" {
  type                      = "Microsoft.CognitiveServices/accounts/raiPolicies@2023-10-01-preview"
  name                      = "${local.account_name}-rai-policy"
  parent_id                 = azurerm_cognitive_account.this.id
  schema_validation_enabled = false
  body = {
    properties = {
      mode           = "Default"
      basePolicyName = "Microsoft.Default"
      contentFilters = [
        { name = "Hate", blocking = true, enabled = true, allowedContentLevel = "Medium", source = "Prompt" },
        { name = "Sexual", blocking = true, enabled = true, allowedContentLevel = "Low", source = "Prompt" },
        { name = "SelfHarm", blocking = true, enabled = true, allowedContentLevel = "Medium", source = "Prompt" },
        { name = "Violence", blocking = true, enabled = true, allowedContentLevel = "Medium", source = "Prompt" },
        { name = "Hate", blocking = true, enabled = true, allowedContentLevel = "Low", source = "Completion" },
        { name = "Sexual", blocking = true, enabled = true, allowedContentLevel = "Low", source = "Completion" },
        { name = "SelfHarm", blocking = true, enabled = true, allowedContentLevel = "Low", source = "Completion" },
        { name = "Violence", blocking = true, enabled = true, allowedContentLevel = "Low", source = "Completion" },
        { name = "Jailbreak", blocking = false, enabled = true, source = "Prompt" },
        { name = "Indirect Attack", blocking = true, enabled = true, source = "Prompt" },
        { name = "Protected Material Text", blocking = false, enabled = true, source = "Completion" },
        { name = "Protected Material Code", blocking = false, enabled = true, source = "Completion" }
      ]
    }
  }
  depends_on = [
    azurerm_cognitive_account.this
  ]
  lifecycle {
    ignore_changes = [body["output"]]
  }
}