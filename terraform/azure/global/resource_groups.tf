module "rg-global" {
  source             = "../modules/resource_group"
  name_suffix        = "global"
  location           = var.location
  full_env_code      = local.full_env_code
  create             = true
  enable_delete_lock = false
}
