data "azurerm_image" "ubuntu" {
  count               = signum(var.deploy_shared_image_gallery ? 1 : 0)
  name_regex          = "^Ubuntu"
  resource_group_name = module.rg-global.name
  sort_descending     = true
}

module "version-ubuntu" {
  source               = "../modules/image_version"
  create                = var.deploy_shared_image_gallery
  global_image_version = var.global_image_version
  gallery_name         = azurerm_shared_image_gallery.image_gallery.*.name[0]
  image_name           = module.image-ubuntu.name
  resource_group_name  = module.rg-global.name
  location             = var.location
  managed_image_id     = data.azurerm_image.ubuntu.*.id[0]
  target_regions       = var.image_target_regions
}

