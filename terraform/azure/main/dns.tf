resource "azurerm_private_dns_zone" "dns-zone" {
  name                = local.dns_zone_name
  resource_group_name = module.rg-network.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns-network-link" {
  name                  = format("%s-%s", azurerm_virtual_network.network.name, "zone-link")
  resource_group_name   = module.rg-network.name
  private_dns_zone_name = azurerm_private_dns_zone.dns-zone.name
  virtual_network_id    = azurerm_virtual_network.network.id
}