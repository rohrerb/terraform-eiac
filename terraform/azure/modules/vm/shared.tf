
resource "azurerm_storage_account" "diag_storage_account" {
  count                    = signum((local.enable_vm_diagnostics && local.instance_count > 0) ? 1 : 0)
  name                     = format("%sdiag", local.base_hostname)
  resource_group_name      = var.resource_group_name
  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  enable_blob_encryption   = true
}

resource "azurerm_advanced_threat_protection" "threat_protection" {
  count              = signum((local.enable_vm_diagnostics && local.instance_count > 0) ? 1 : 0)
  target_resource_id = azurerm_storage_account.diag_storage_account.*.id[0]
  enabled            = false
}


resource "azurerm_availability_set" "av_set" {
  count                        = local.deploy_using_zones || var.number_of_vms_in_avset == 0 ? 0 : signum(local.instance_count)
  name                         = format("%s-AVSet", local.base_hostname)
  location                     = local.location
  resource_group_name          = var.resource_group_name
  managed                      = true
  platform_fault_domain_count  = local.platform_fault_domain_count
  platform_update_domain_count = 20
}

resource "random_password" "vm_password" {
  for_each = { for i in local.items : i.key => i
    if var.os_code == var.os_code_windows
  }

  length  = 16
  special = true
}

