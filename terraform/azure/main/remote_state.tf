resource "azurerm_resource_group" "terraform_storage" {
  count = var.enable_remote_state ? 1 : 0
  name     = format("%s-storage-terraform", local.full_env_code)
  location = var.location
}

resource "azurerm_storage_account" "terraform_storage_account" {
  count = var.enable_remote_state ? 1 : 0
  name                      = format("%sterraform", local.full_env_code)
  resource_group_name       = azurerm_resource_group.terraform_storage.*.name[0]
  location                  = var.location
  account_tier              = "Standard"
  account_replication_type  = "RAGRS"
  account_kind              = "StorageV2"
  enable_blob_encryption    = true
  enable_https_traffic_only = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_storage_management_policy" "life_cycle_management" {
  count = var.enable_remote_state ? 1 : 0
  storage_account_id = azurerm_storage_account.terraform_storage_account.*.id[0]

  rule {
    name    = "terraformstateexpiration"
    enabled = true
    filters {
      prefix_match = [azurerm_storage_container.terraform_storage_container.*.name[0]]
      blob_types   = ["blockBlob"]
    }
    actions {
      snapshot {
        delete_after_days_since_creation_greater_than = 30
      }
    }
  }
}

resource "azurerm_management_lock" "terraform_storage_account" {
  count = var.enable_remote_state ? 1 : 0
  name       = "terraform_storage_account_lock"
  lock_level = "CanNotDelete"
  scope      = azurerm_storage_account.terraform_storage_account.*.id[0]
}

resource "azurerm_storage_container" "terraform_storage_container" {
  count = var.enable_remote_state ? 1 : 0
  name                  = "main"
  storage_account_name  = azurerm_storage_account.terraform_storage_account.*.name[0]
  container_access_type = "private"
}