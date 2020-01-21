
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azurerm_recovery_services_vault" "vault" {
  count               = signum(var.create ? 1 : 0)
  name                = format("%s-%s", var.full_env_code, "recovery-vault")
  resource_group_name = var.resource_group_name
  location            = var.location_secondary
  sku                 = var.sku
}

resource "azurerm_site_recovery_fabric" "primary" {
  count = signum(var.create ? 1 : 0)

  name                = "primary-fabric"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.vault.*.name[0]
  location            = var.location_primary
}

resource "azurerm_site_recovery_fabric" "secondary" {
  count               = signum(var.create ? 1 : 0)
  name                = "secondary-fabric"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.vault.*.name[0]
  location            = var.location_secondary
}

resource "azurerm_site_recovery_protection_container" "primary" {
  count                = signum(var.create ? 1 : 0)
  name                 = "primary-protection-container"
  resource_group_name  = var.resource_group_name
  recovery_vault_name  = azurerm_recovery_services_vault.vault.*.name[0]
  recovery_fabric_name = azurerm_site_recovery_fabric.primary.*.name[0]
}

resource "azurerm_site_recovery_protection_container" "secondary" {
  count                = signum(var.create ? 1 : 0)
  name                 = "secondary-protection-container"
  resource_group_name  = var.resource_group_name
  recovery_vault_name  = azurerm_recovery_services_vault.vault.*.name[0]
  recovery_fabric_name = azurerm_site_recovery_fabric.secondary.*.name[0]
}

resource "azurerm_site_recovery_replication_policy" "policy" {
  count                                                = signum(var.create ? 1 : 0)
  name                                                 = "policy"
  resource_group_name                                  = var.resource_group_name
  recovery_vault_name                                  = azurerm_recovery_services_vault.vault.*.name[0]
  recovery_point_retention_in_minutes                  = var.recovery_point_retention_in_minutes
  application_consistent_snapshot_frequency_in_minutes = var.application_consistent_snapshot_frequency_in_minutes
}

resource "azurerm_site_recovery_protection_container_mapping" "container-mapping" {
  count                                     = signum(var.create ? 1 : 0)
  name                                      = "container-mapping"
  resource_group_name                       = var.resource_group_name
  recovery_vault_name                       = azurerm_recovery_services_vault.vault.*.name[0]
  recovery_fabric_name                      = azurerm_site_recovery_fabric.primary.*.name[0]
  recovery_source_protection_container_name = azurerm_site_recovery_protection_container.primary.*.name[0]
  recovery_target_protection_container_id   = azurerm_site_recovery_protection_container.secondary.*.id[0]
  recovery_replication_policy_id            = azurerm_site_recovery_replication_policy.policy.*.id[0]
}

resource "azurerm_storage_account" "primary" {
  count                    = signum(var.create ? 1 : 0)
  name                     = format("%s%s", lower(var.full_env_code), "vaultrecovcache")
  location                 = var.location_primary
  resource_group_name      = var.resource_group_name_for_recoverycache
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_advanced_threat_protection" "threat_protection" {
  count                    = 0 #signum(var.create ? 1 : 0)
  target_resource_id = azurerm_storage_account.primary.*.id[0]
  enabled = false
}

resource "azurerm_site_recovery_network_mapping" "recovery-network-mapping" {
  count                       = signum(var.create ? 1 : 0)
  name                        = "recovery-network-mapping-secondary"
  resource_group_name         = var.resource_group_name
  recovery_vault_name         = azurerm_recovery_services_vault.vault.*.name[0]
  source_recovery_fabric_name = azurerm_site_recovery_fabric.primary.*.name[0]
  target_recovery_fabric_name = azurerm_site_recovery_fabric.secondary.*.name[0]
  source_network_id           = var.network_id_primary
  target_network_id           = var.network_id_secondary
}