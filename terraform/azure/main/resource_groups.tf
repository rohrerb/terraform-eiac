module "rg-dmz" {
  source             = "../modules/resource_group"
  name_suffix        = "dmz"
  location           = var.location
  full_env_code      = upper(local.full_env_code)
  create             = true
  enable_delete_lock = false
}

module "rg-services" {
  source             = "../modules/resource_group"
  name_suffix        = "services"
  location           = var.location
  full_env_code      = upper(local.full_env_code)
  create             = true
  enable_delete_lock = false
}

module "rg-management" {
  source             = "../modules/resource_group"
  name_suffix        = "management"
  location           = var.location
  full_env_code      = upper(local.full_env_code)
  create             = true
  enable_delete_lock = false
}

module "rg-data" {
  source             = "../modules/resource_group"
  name_suffix        = "data"
  location           = var.location
  full_env_code      = upper(local.full_env_code)
  create             = true
  enable_delete_lock = false
}


module "rg-network" {
  source             = "../modules/resource_group"
  name_suffix        = "network"
  location           = var.location
  full_env_code      = upper(local.full_env_code)
  create             = true
  enable_delete_lock = false
}

module "rg-network-secondary" {
  source             = "../modules/resource_group"
  name_suffix        = "network"
  location           = var.location_secondary
  full_env_code      = upper(local.full_env_code_secondary)
  create             = var.enable_secondary
  enable_delete_lock = false
}

module "rg-packer" {
  source             = "../modules/resource_group"
  name_suffix        = "packer"
  location           = var.location
  full_env_code      = upper(local.full_env_code)
  create             = true
  enable_delete_lock = false
}

module "rg-recovery-vault" {
  source             = "../modules/resource_group"
  name_suffix        = "recovery-vault"
  location           = var.location_secondary
  full_env_code      = upper(local.full_env_code_secondary)
  create             = true
  enable_delete_lock = false
}