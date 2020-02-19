locals {

  full_env_code           = format("%s%s%s", lower(var.environment_code), lower(var.deployment_code), lower(var.location_code))
  full_env_code_secondary = format("%s%s%s", lower(var.environment_code), lower(var.deployment_code), lower(var.location_code_secondary))
  dns_zone_name           = format("pz.io")
  default_tags            = {}
  default_ip_whitelist    = []
  proxy                   = format("%s%s", "lsqd.", local.dns_zone_name)
  subnet_id_app           = length(azurerm_subnet.subnet) > 0 ? azurerm_subnet.subnet["app"].id : null
  subnet_id_data          = length(azurerm_subnet.subnet) > 0 ? azurerm_subnet.subnet["data"].id : null
  subnet_id_dmz           = length(azurerm_subnet.subnet) > 0 ? azurerm_subnet.subnet["dmz"].id : null
  subnet_id_management    = length(azurerm_subnet.subnet) > 0 ? azurerm_subnet.subnet["management"].id : null
  subnet_id_services      = length(azurerm_subnet.subnet) > 0 ? azurerm_subnet.subnet["services"].id : null
  subnet_id_bastion       = length(azurerm_subnet.subnet) > 0 ? azurerm_subnet.subnet["AzureBastionSubnet"].id : null

  dep_generic_map = {
    full_env_code               = local.full_env_code
    platform_fault_domain_count = var.platform_fault_domain_count
    location                    = var.location
    location_secondary          = var.location_secondary
    ssh_key_path                = var.ssh_key_path
    deploy_using_zones          = var.deploy_using_zones
    recovery_services_map       = jsonencode(module.recovery-vault.outputs)
    dns_zone_name               = azurerm_private_dns_zone.dns-zone.name
    network_resource_group      = module.rg-network.name
    enable_log_analytics        = var.enable_log_analytics
    log_analytics_worspace_id   = var.enable_log_analytics ? azurerm_log_analytics_workspace.workspace.*.workspace_id[0] : null
    log_analytics_worspace_key  = var.enable_log_analytics ? azurerm_log_analytics_workspace.workspace.*.primary_shared_key[0] : null
  }
}
