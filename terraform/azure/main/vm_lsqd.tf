locals {
  lsqd_instance_map = lookup(var.vm_instance_maps, "lsqd")
  lsqd_count        = lookup(local.lsqd_instance_map, "count", 0)
}

module "lsqd-nsg" {
  source               = "../modules/nsg"
  create               = (signum(local.lsqd_count) == 0 ? false : true)
  full_env_code        = local.full_env_code
  name                 = "lsqd-nsg"
  location             = var.location
  resource_group_name  = module.rg-dmz.name
  apply_ssh_rule       = false
  default_ip_whitelist = local.default_ip_whitelist
}

module "lsqd-nsg-rules" {
  source                      = "../modules/nsg_rule"
  create                      = (signum(local.lsqd_count) == 0 ? false : true)
  resource_group_name         = module.rg-dmz.name
  network_security_group_name = module.lsqd-nsg.name
  location                    = var.location
  rules_map = {
    squid   = { priority = 150, direction = "Inbound", access = "Allow", protocol = "TCP", destination_port_range = 3128 },
  }
}

module "lsqd" {
  source = "../modules/vm"

  vm_generic_map  = local.vm_generic_map
  vm_instance_map = local.lsqd_instance_map

  os_code                = var.os_code_linux
  instance_type          = "sqd"
  number_of_vms_in_avset = local.lsqd_count
  resource_group_name    = module.rg-dmz.name
  os_disk_image_id       = data.azurerm_image.ubuntu.id

  subnet_id                 = azurerm_subnet.subnet["dmz"].id
  network_security_group_id = local.lsqd_count == 0 ? "" : module.lsqd-nsg.id

  cloud_init_vars = {
    network_octets = var.network_octets
  }
}