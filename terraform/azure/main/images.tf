

# data "azurerm_image" "windows" {
#   name_regex          = "^Windows_2019"
#   resource_group_name = module.rg-packer.name
#   sort_descending     = true
# }

# data "azurerm_image" "centos" {
#   name_regex          = "^Centos_"
#   resource_group_name = module.rg-packer.name
#   sort_descending     = true
# }

data "azurerm_image" "ubuntu" {
  name_regex          = "^Ubuntu"
  resource_group_name = module.rg-packer.name
  sort_descending     = true
}

data "azurerm_shared_image_version" "ubuntu" {
  provider            = "azurerm.global"

  name                = var.global_image_version
  image_name          = "Ubuntu"
  gallery_name        = "global_image_gallery"
  resource_group_name = "Global"
}

