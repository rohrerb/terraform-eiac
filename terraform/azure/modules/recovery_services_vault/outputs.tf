
output "outputs" {
  # element() avoids TF warning due to the use of count in the module
  value = {
    "id"                                = element(concat(azurerm_recovery_services_vault.vault.*.id, list("")), 0),
    "name"                              = format("%s-%s", var.full_env_code, "recovery-vault"),
    "primary_fabric_name"               = element(concat(azurerm_site_recovery_fabric.primary.*.name, list("")), 0),
    "replication_policy_id"             = element(concat(azurerm_site_recovery_replication_policy.policy.*.id, list("")), 0),
    "secondary_fabric_id"               = element(concat(azurerm_site_recovery_fabric.secondary.*.id, list("")), 0),
    "primary_protection_container_name" = element(concat(azurerm_site_recovery_protection_container.primary.*.name, list("")), 0),
    "secondary_protection_container_id" = element(concat(azurerm_site_recovery_protection_container.secondary.*.id, list("")), 0),
    "staging_storage_account_id"        = element(concat(azurerm_storage_account.primary.*.id, list("")), 0),
    "resource_group_name"               = data.azurerm_resource_group.rg.name,
    "resource_group_id"                 = data.azurerm_resource_group.rg.id
  }
}


output "id" {
  # element() avoids TF warning due to the use of count in the module
  value = element(concat(azurerm_recovery_services_vault.vault.*.id, list("")), 0)
}

output "name" {
  # element() avoids TF warning due to the use of count in the module
  value = format("%s-%s", var.full_env_code, "recovery-vault")
}

output "primary_fabric_name" {
  # element() avoids TF warning due to the use of count in the module
  value = element(concat(azurerm_site_recovery_fabric.primary.*.name, list("")), 0)
}

output "replication_policy_id" {
  # element() avoids TF warning due to the use of count in the module
  value = element(concat(azurerm_site_recovery_replication_policy.policy.*.id, list("")), 0)
}

output "secondary_fabric_id" {
  # element() avoids TF warning due to the use of count in the module
  value = element(concat(azurerm_site_recovery_fabric.secondary.*.id, list("")), 0)
}

output "primary_protection_container_name" {
  # element() avoids TF warning due to the use of count in the module
  value = element(concat(azurerm_site_recovery_protection_container.primary.*.name, list("")), 0)
}

output "secondary_protection_container_id" {
  # element() avoids TF warning due to the use of count in the module
  value = element(concat(azurerm_site_recovery_protection_container.secondary.*.id, list("")), 0)
}

output "staging_storage_account_id" {
  # element() avoids TF warning due to the use of count in the module
  value = element(concat(azurerm_storage_account.primary.*.id, list("")), 0)
}





