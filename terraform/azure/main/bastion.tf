
module "bastion" {
  source = "../modules/bastion"

  create        = var.enable_bastion
  full_env_code = local.full_env_code

  location            = var.location
  resource_group_name = module.rg-network.name
  subnet_id           = local.subnet_id_bastion
}