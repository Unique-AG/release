locals {
  dbs = [
    "chat",
    "ingestion",
    "theme",
    "scope-management",
    "app-repository"
  ]
}
resource "azurerm_postgresql_flexible_server_database" "this" {
  for_each  = toset(local.dbs)
  name      = lower(each.value)
  server_id = var.postgres_server_id
  lifecycle {
    ignore_changes = [
      collation
    ]
  }
}