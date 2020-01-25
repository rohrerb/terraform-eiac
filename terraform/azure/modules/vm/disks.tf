

resource "azurerm_managed_disk" "data_disk" {
  for_each = { for i in local.disks : i.key => i }

  name                 = format("%s%s", local.full_env_code, each.key)
  location             = local.location
  resource_group_name  = var.resource_group_name
  storage_account_type = var.storage_type
  create_option        = "Empty"
  disk_size_gb         = local.data_disk_size
  zones                = local.deploy_using_zones ? azurerm_virtual_machine.vm[each.value.vm_key].zones : null
}

resource "azurerm_virtual_machine_data_disk_attachment" "data_disk_attach" {
  for_each = { for i in local.disks : i.key => i }

  virtual_machine_id = azurerm_virtual_machine.vm[each.value.vm_key].id
  managed_disk_id    = azurerm_managed_disk.data_disk[each.key].id
  lun                = each.value.lun
  caching            = "ReadOnly"
}
