resource "azurerm_virtual_machine" "vm" {
  for_each = { for i in local.items : i.key => i }

  name                  = format("%s%03d", local.base_hostname, each.value.index)
  location              = local.location
  resource_group_name   = var.resource_group_name
  availability_set_id   = var.number_of_vms_in_avset == 0 ? "" : element(concat(azurerm_availability_set.av_set.*.id, list("")), 0)
  vm_size               = var.vm_instance_map.size
  network_interface_ids = [azurerm_network_interface.vm_nic[each.key].id]

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  lifecycle {
    prevent_destroy = false

    ignore_changes = [
      #storage_image_reference,
      os_profile
    ]
  }

/*
  storage_image_reference {
    id = var.os_disk_image_id
  }
*/

   storage_image_reference {
    publisher = "OpenLogic"
    offer     = "Centos"
    sku       = "7.7"
    version   = "latest"
  } 


  storage_os_disk {
    name              = format("%s%03d-%s", local.base_hostname, each.value.index, "osdisk")
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = var.storage_type
    disk_size_gb      = local.os_disk_size
    os_type           = (var.os_code == var.os_code_windows ? "Windows" : "Linux")
  }

  dynamic "os_profile_linux_config" {
    for_each = { for o in range(0, 1) : o => o
    if var.os_code == var.os_code_linux }

    content {
      disable_password_authentication = false
      
      ssh_keys {
        path     = format("/home/%s/.ssh/authorized_keys", var.admin_username)
        key_data = file(local.ssh_key_path)
      }
      
    }
  }

  dynamic "os_profile_windows_config" {
    for_each = { for o in range(0, 1) : o => o
    if var.os_code == var.os_code_windows }

    content {
      enable_automatic_upgrades = false
      provision_vm_agent        = true
    }
  }

  os_profile {
    computer_name  = each.value.full_name
    admin_username = var.admin_username
    admin_password = (var.os_code == var.os_code_windows ? random_password.vm_password[each.key].result : "")
    custom_data    = (var.os_code == var.os_code_windows ? "" : data.template_file.cloudconfig[each.key].rendered)
  }

  dynamic "boot_diagnostics" {
    for_each = { for o in range(0, 1) : o => o
    if local.enable_vm_diagnostics }

    content {
      enabled     = true
      storage_uri = azurerm_storage_account.diag_storage_account.0.primary_blob_endpoint
  }
  }


  provisioner "local-exec" {
    command     = "echo '${format("%s%s%s", each.value.full_name, " ", (var.os_code == var.os_code_windows ? random_password.vm_password[each.key].result : "ssh_only"))}'"
  
    interpreter = ["/bin/bash", "-c"]
  }
}