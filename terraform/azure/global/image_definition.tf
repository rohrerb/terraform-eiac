module "image-ubuntu" {
  source              = "../modules/image_definition"
  name                = "Ubuntu"
  create               = var.deploy_shared_image_gallery 
  location            = var.location
  gallery_name        = azurerm_shared_image_gallery.image_gallery.*.name[0]
  resource_group_name = module.rg-global.name
  os_type             = "Linux"
  offer               = "Ubuntu"
  sku                 = "Base"
}