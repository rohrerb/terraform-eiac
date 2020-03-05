resource "azurerm_public_ip" "vm_pip" {
  for_each = { for i in local.items : i.key => i
  if local.enable_public_ip }

  name                = format("%s-pip", each.value.full_name)
  location            = local.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = format("%s", each.value.full_name)
}

resource "azurerm_network_interface" "vm_nic" {
  for_each = { for i in local.items : i.key => i }

  name                      = format("%s-nic", each.value.full_name)
  location                  = local.location
  resource_group_name       = var.resource_group_name
  enable_ip_forwarding      = var.ip_forwarding

  # With Public IP
  dynamic "ip_configuration" {
    for_each = { for o in range(0, 1) : o => o
    if local.enable_public_ip }

    content {
      name                          = "ipconfig"
      subnet_id                     = var.subnet_id
      private_ip_address_allocation = "dynamic"
      public_ip_address_id          = azurerm_public_ip.vm_pip[each.key].id
    }
  }

  dynamic "ip_configuration" {
    for_each = { for o in range(0, 1) : o => o
    if ! local.enable_public_ip }

    content {
      name                          = "ipconfig"
      subnet_id                     = var.subnet_id
      private_ip_address_allocation = "dynamic"
    }
  }
}

resource "azurerm_network_interface_security_group_association" "vm_nic_nsg_association" {
  for_each = { for i in local.items : i.key => i }

  network_interface_id      = azurerm_network_interface.vm_nic[each.key].id
  network_security_group_id = var.network_security_group_id
}


resource "azurerm_network_interface_backend_address_pool_association" "nic_backend_pool_association_internal" {
  for_each = { for i in local.items : i.key => i
    if var.enable_internal_lb
  }

  network_interface_id    = azurerm_network_interface.vm_nic[each.key].id
  ip_configuration_name   = "ipconfig"
  backend_address_pool_id = var.backend_address_pool_id_internal
}

resource "azurerm_network_interface_backend_address_pool_association" "nic_backend_pool_association_external" {
  for_each = { for i in local.items : i.key => i
    if var.enable_external_lb
  }

  network_interface_id    = azurerm_network_interface.vm_nic[each.key].id
  ip_configuration_name   = "ipconfig"
  backend_address_pool_id = var.backend_address_pool_id_external
}
