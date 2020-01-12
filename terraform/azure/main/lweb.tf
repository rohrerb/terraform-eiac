locals {
  lweb_instance_map = lookup(var.vm_instance_maps, "lweb")
  lweb_count        = lookup(local.lweb_instance_map, "count", 0)
}

module "lweb-nsg" {
  source               = "../modules/nsg"
  create               = false # (signum(local.lweb_count) == 0 ? false : true)
  full_env_code        = local.full_env_code
  name                 = "lweb-nsg"
  location             = var.location
  resource_group_name  = module.rg-dmz.name
  apply_ssh_rule       = true
  default_ip_whitelist = local.default_ip_whitelist
}

module "lweb-nsg-rules" {
  source                      = "../modules/nsg_rule"
  create                      = false # (signum(local.lweb_count) == 0 ? false : true)
  resource_group_name         = module.rg-dmz.name
  network_security_group_name = module.lweb-nsg.name
  location                    = var.location
  rules_map = {
    http_inbound   = { priority = 150, direction = "Inbound", access = "Allow", protocol = "TCP", source_port_range = "80" },
    https_outbound = { priority = 151, direction = "Inbound", access = "Allow", protocol = "TCP", source_port_range = "443" }
  }
}

module "lweb-lb" {
  source              = "../modules/lb_public"
  name                = "lweb"
  full_env_code       = local.full_env_code
  create              = false #(signum(local.lweb_count) == 0 ? false : true)
  location            = var.location
  resource_group_name = module.rg-dmz.name
  subnet_id           = azurerm_subnet.subnet["DMZ"].id
  port                = 80
  probe_port          = 80
  timeout             = 4
}

module "lweb" {
  source = "../modules/vm"

  vm_generic_map  = local.vm_generic_map
  vm_instance_map = local.lweb_instance_map

  os_code       = var.os_code_linux
  instance_type = "web"
  number_of_vms_in_avset = local.lweb_count
  resource_group_name = module.rg-dmz.name
  os_disk_image_id    = data.azurerm_image.centos.id

  subnet_id                 = azurerm_subnet.subnet["DMZ"].id
  #network_security_group_id = local.lweb_count == 0 ? "" : module.lweb-nsg.id

  #enable_external_lb               = local.lweb_count == 0 ? false : true
  #backend_address_pool_id_external = module.lweb-lb.backend_pool_id
  
}