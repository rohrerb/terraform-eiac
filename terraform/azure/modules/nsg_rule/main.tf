
resource "azurerm_network_security_rule" "nsg-rule" {
  for_each = (var.create ? var.rules_map : {})

  name                        = each.key
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = lookup(each.value, "source_port_range", "*")
  destination_port_range      = lookup(each.value, "destination_port_range", "*")
  source_address_prefix       = lookup(each.value, "source_address_prefix", "*")
  destination_address_prefix  = lookup(each.value, "destination_address_prefix", "*")
  resource_group_name         = var.resource_group_name
  network_security_group_name = var.network_security_group_name
}
