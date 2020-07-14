resource "azurerm_virtual_network" "network" {
  name                = format("%s-net", local.full_env_code)
  resource_group_name = module.rg-network.name
  address_space       = [format("%s%s", var.network_octets, ".0.0/16")]
  location            = var.location

  dns_servers = var.dns_servers

  tags = local.default_tags
}

resource "azurerm_subnet" "subnet" {
  for_each = var.subnet

  name                 = each.key
  resource_group_name  = module.rg-network.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes       = [format("%s.%s.%s", var.network_octets, each.value.subnet_octet, "0/24")]
  service_endpoints    = each.value.service_endpoints
}

resource "azurerm_virtual_network" "network_secondary" {
  count = signum(var.enable_secondary ? 1 : 0)

  name                = format("%s-net", local.full_env_code_secondary)
  resource_group_name = module.rg-network-secondary.name
  address_space       = [format("%s%s", var.network_octets_secondary, ".0.0/16")]
  location            = var.location_secondary

  dns_servers = var.dns_servers

  tags = local.default_tags
}

resource "azurerm_subnet" "subnet_secondary" {
  for_each = var.enable_secondary ? var.subnet : {}

  name                 = each.key
  resource_group_name  = module.rg-network-secondary.name
  virtual_network_name = azurerm_virtual_network.network_secondary.*.name[0]
  address_prefixes       = [format("%s.%s.%s", var.network_octets_secondary, each.value.subnet_octet, "0/24")]
  service_endpoints    = each.value.service_endpoints
}


resource "azurerm_virtual_network_peering" "network_peering" {
  count                        = signum(var.enable_secondary ? 1 : 0)
  name                         = format("%s-peering2secondary", local.full_env_code)
  resource_group_name          = module.rg-network.name
  virtual_network_name         = azurerm_virtual_network.network.name
  remote_virtual_network_id    = azurerm_virtual_network.network_secondary.*.id[0]
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "network_secondary_peering" {
  count                        = signum(var.enable_secondary ? 1 : 0)
  name                         = format("%s-peering2primary", local.full_env_code_secondary)
  resource_group_name          = module.rg-network-secondary.name
  virtual_network_name         = azurerm_virtual_network.network_secondary.*.name[0]
  remote_virtual_network_id    = azurerm_virtual_network.network.id
  allow_virtual_network_access = true
}

resource "azurerm_network_watcher" "watcher" {
  name                = format("%s-watcher", local.full_env_code)
  location            = var.location
  resource_group_name = module.rg-network.name
}

resource "azurerm_network_watcher" "watcher_secondary" {
  count               = signum(var.enable_secondary ? 1 : 0)
  name                = format("%s-watcher", local.full_env_code_secondary)
  location            = var.location_secondary
  resource_group_name = module.rg-network-secondary.name
}

