resource "azurerm_shared_image_gallery" "image_gallery" {
  count               = var.deploy_shared_image_gallery ? 1 : 0
  name                = format("%s", "global_image_gallery")
  resource_group_name = module.rg-global.name
  location            = var.location
  description         = "Global Images"
}
