resource "local_file" "packer_config" {
  content = jsonencode(
    {
      "subscription_id"        = var.subscription_id
      "location"               = var.location
      "cloud_environment_name" = (var.is_azure_government ? "USGovernment" : "Public")
      "resource_group"         = module.rg-packer.name
      "proxy"                  = format("%s%s", "lsqd.", local.dns_zone_name)
      "virtual_network_name"   = azurerm_virtual_network.network.name
      "virtual_network_subnet_name" = azurerm_subnet.subnet["management"].name
      "virtual_network_resource_group_name" =  module.rg-network.name
  })
  filename = format("%s/../packer/deployments/%s.json", path.module, var.deployment_code)
}
