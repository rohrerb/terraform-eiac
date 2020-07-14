resource "azurerm_shared_image_version" "version" {
  count               = var.create ? 1 : 0
  name                = var.global_image_version
  gallery_name        = var.gallery_name
  image_name          = var.image_name
  resource_group_name = var.resource_group_name
  location            = var.location
  managed_image_id    = var.managed_image_id


  dynamic "target_region" {
    iterator = region
    for_each = var.target_regions
    content {
      name                   = region.value
      regional_replica_count = 1
    }
  }
}
