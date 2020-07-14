resource "azurerm_shared_image" "image" {
  count               = var.create ? 1 : 0
  name                = var.name
  gallery_name        = var.gallery_name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = var.os_type

  identifier {
    publisher = "Custom"
    offer     = var.offer
    sku       = var.sku
  }
}
