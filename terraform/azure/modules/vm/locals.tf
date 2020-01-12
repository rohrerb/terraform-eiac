locals {

  platform_fault_domain_count = var.vm_generic_map.platform_fault_domain_count
  full_env_code               = var.vm_generic_map.full_env_code
  ssh_key_path                = var.vm_generic_map.ssh_key_path
  location                    = var.vm_generic_map.location
  location_secondary          = var.vm_generic_map.location_secondary
  recovery_services_map       = jsondecode(var.vm_generic_map.recovery_services_map)

  base_hostname    = format("%s%s%s", local.full_env_code, var.os_code, var.instance_type)
  instance_count   = tonumber(var.vm_instance_map.count)
  data_disk_count  = tonumber(lookup(var.vm_instance_map, "data_disk_count", 0))
  data_disk_size   = tonumber(lookup(var.vm_instance_map, "data_disk_size", 0))
  os_disk_size     = tonumber(lookup(var.vm_instance_map, "os_disk_size", 128))
  enable_recovery  = tobool(lookup(var.vm_instance_map, "enable_recovery", false))
  enable_public_ip = tobool(lookup(var.vm_instance_map, "enable_public_ip", false))
  enable_vm_diagnostics = tobool(lookup(var.vm_instance_map, "enable_vm_diagnostics", false))


  items = [for i in range(0, local.instance_count) :
    { "key"       = format("%s%s%03d", var.os_code, var.instance_type, i + 1),
      "full_name" = format("%s%03d", local.base_hostname, i + 1)
      "index"     = i + 1
  }]

  disks = [for i in range(0, local.instance_count * local.data_disk_count) :
    { "key"    = format("%s%s%03d-dd-%02d", var.os_code, var.instance_type, ceil((i + 1) * 1.0 / local.data_disk_count), (i % local.data_disk_count) + 1),
      "lun"    = i % local.data_disk_count,
      "vm_key" = format("%s%s%03d", var.os_code, var.instance_type, ceil((i + 1) * 1.0 / local.data_disk_count))
  }]
}

/*
output "items" {
  value = flatten(local.items)
}

output "disks" {
  value = flatten(local.disks)
}
*/