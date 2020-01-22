resource "azurerm_resource_group" "rg" {
  count    = signum(var.create ? 1 : 0)
  name     = format("%s-%s", var.full_env_code, lower(var.name_suffix))
  location = var.location
  tags     = var.tags
}

resource "azurerm_management_lock" "lock" {
  count = signum(var.create && var.enable_delete_lock ? 1 : 0)

  name       = "DoNotDelete"
  scope      = azurerm_resource_group.rg.*.id[0]
  lock_level = "ReadOnly"
  notes      = "This Resource Group is can't be Deleted."
}

