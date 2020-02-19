resource "azurerm_log_analytics_workspace" "workspace" {
  count               = signum(var.enable_log_analytics ? 1 : 0)
  name                = lower(format("%s-analytics", local.full_env_code))
  location            = var.log_analytics_location_override == null ? var.location : var.log_analytics_location_override
  resource_group_name = module.rg-management.name
  sku                 = "PerNode"
  retention_in_days   = 30
}

resource "azurerm_automation_account" "automation" {
  count               = signum(var.enable_log_analytics ? 1 : 0)
  name                = lower(format("%s-automation", local.full_env_code))
  location            = var.log_analytics_location_override == null ? var.location : var.log_analytics_location_override
  resource_group_name = module.rg-management.name

  sku_name = "Basic"
}

resource "azurerm_log_analytics_solution" "update_management" {
  count                 = signum(var.enable_log_analytics ? 1 : 0)
  solution_name         = "Updates"
  location              = var.log_analytics_location_override == null ? var.location : var.log_analytics_location_override
  resource_group_name   = module.rg-management.name
  workspace_resource_id = azurerm_log_analytics_workspace.workspace.*.id[0]
  workspace_name        = azurerm_log_analytics_workspace.workspace.*.name[0]

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Updates"
  }
}