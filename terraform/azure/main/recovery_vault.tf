
module "recovery-vault" {
  source = "../modules/recovery_services_vault"

  create        = (var.enable_recovery_services && var.enable_secondary)
  full_env_code = local.full_env_code_secondary

  location_primary   = var.location
  location_secondary = var.location_secondary

  network_id_primary   = azurerm_virtual_network.network.id
  network_id_secondary = azurerm_virtual_network.network_secondary.*.id[0]

  resource_group_name                   = module.rg-recovery-vault.name
  resource_group_name_for_recoverycache = module.rg-management.name
}
