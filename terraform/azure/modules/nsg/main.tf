resource "azurerm_network_security_group" "nsg" {
  count               = (var.create ? 1 : 0)
  name                = format("%s-%s", var.full_env_code, lower(var.name))
  location            = var.location
  resource_group_name = var.resource_group_name
}

#Default RULES Only

resource "azurerm_network_security_rule" "nsg-rule-rdp" {
  count                       = (var.create && var.apply_rdp_rule) ? 1 : 0
  name                        = "rDP"
  priority                    = "105"
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = 3389
  source_address_prefixes     = var.default_ip_whitelist
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.*.name[count.index]
}

resource "azurerm_network_security_rule" "nsg-rule-ssh" {
  count                       = (var.create && var.apply_ssh_rule) ? 1 : 0
  name                        = "SSH"
  priority                    = "110"
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = 22
  source_address_prefixes     = var.default_ip_whitelist
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.*.name[count.index]
}

resource "azurerm_network_security_rule" "nsg-rule-tcp-block" {
  count                       = (var.create && var.apply_tcp_block_rule) ? 1 : 0
  name                        = "TCP_Block"
  description                 = "TCP Deny"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.*.name[count.index]
}

resource "azurerm_network_security_rule" "nsg-rule-udp-block" {
  count                       = (var.create && var.apply_udp_block_rule) ? 1 : 0
  name                        = "UDP_Block"
  description                 = "UDP Deny"
  priority                    = 201
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "UDP"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.*.name[count.index]
}
