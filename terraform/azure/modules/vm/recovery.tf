
resource "azurerm_site_recovery_replicated_vm" "vm-replication" {
  for_each = { for vm in azurerm_virtual_machine.vm : vm.id => vm
    if local.enable_recovery
  }

  name = format("%s-replication", each.value.name)

  resource_group_name                       = local.recovery_services_map.resource_group_name
  recovery_vault_name                       = local.recovery_services_map.name
  source_recovery_fabric_name               = local.recovery_services_map.primary_fabric_name
  source_vm_id                              = each.value.id
  recovery_replication_policy_id            = local.recovery_services_map.replication_policy_id
  source_recovery_protection_container_name = local.recovery_services_map.primary_protection_container_name

  target_resource_group_id                = local.recovery_services_map.resource_group_id
  target_recovery_fabric_id               = local.recovery_services_map.secondary_fabric_id
  target_recovery_protection_container_id = local.recovery_services_map.secondary_protection_container_id

  managed_disk {
    disk_id                    = each.value.storage_os_disk.0.managed_disk_id
    staging_storage_account_id = local.recovery_services_map.staging_storage_account_id
    target_resource_group_id   = local.recovery_services_map.resource_group_id
    target_disk_type           = var.storage_type
    target_replica_disk_type   = var.storage_type
  }

  dynamic "managed_disk" {
    for_each = { for dd in azurerm_virtual_machine_data_disk_attachment.data_disk_attach : dd.id => dd
    if dd.virtual_machine_id == each.value.id }

    content {
      disk_id                    = managed_disk.value.managed_disk_id
      staging_storage_account_id = local.recovery_services_map.staging_storage_account_id
      target_resource_group_id   = local.recovery_services_map.resource_group_id
      target_disk_type           = var.storage_type
      target_replica_disk_type   = var.storage_type
    }
  }
}
