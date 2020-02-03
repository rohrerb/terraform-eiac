locals {
  lngx_instance_map = lookup(var.vm_instance_maps, "lngx")
  lngx_count        = lookup(local.lngx_instance_map, "count", 0)
}

module "lngx-nsg" {
  source               = "../modules/nsg"
  create               = (signum(local.lngx_count) == 0 ? false : true)
  full_env_code        = local.full_env_code
  name                 = "lngx-nsg"
  location             = var.location
  resource_group_name  = module.rg-dmz.name
  apply_ssh_rule       = false
  default_ip_whitelist = local.default_ip_whitelist
}

module "lngx-nsg-rules" {
  source                      = "../modules/nsg_rule"
  create                      = (signum(local.lngx_count) == 0 ? false : true)
  resource_group_name         = module.rg-dmz.name
  network_security_group_name = module.lngx-nsg.name
  location                    = var.location
  rules_map = {
    http_inbound   = { priority = 150, direction = "Inbound", access = "Allow", protocol = "TCP", destination_port_range = "80" },
    https_inbound = { priority = 151, direction = "Inbound", access = "Allow", protocol = "TCP", destination_port_range = "443" }
  }
}

module "lngx-lb" {
  source              = "../modules/lb"
  name                = "lngx"
  full_env_code       = local.full_env_code
  create              = (signum(local.lngx_count) == 0 ? false : true)
  is_public           = true
  sku                 = "Standard"
  location            = var.location
  resource_group_name = module.rg-dmz.name
  subnet_id           = azurerm_subnet.subnet["dmz"].id
  probe_port          = 80

  rules_map = {
    http_rule = { protocol = "TCP", frontend_port = 80, backend_port = 80, public_frontend = true  }
  }
}

module "lngx" {
  source = "../modules/vm"

  vm_generic_map  = local.vm_generic_map
  vm_instance_map = local.lngx_instance_map

  os_code                = var.os_code_linux
  instance_type          = "ngx"
  number_of_vms_in_avset = local.lngx_count
  resource_group_name    = module.rg-dmz.name
  os_disk_image_id       = data.azurerm_image.ubuntu.id

  subnet_id                 = azurerm_subnet.subnet["dmz"].id
  network_security_group_id = local.lngx_count == 0 ? "" : module.lngx-nsg.id

  enable_external_lb               = local.lngx_count == 0 ? false : true
  backend_address_pool_id_external = module.lngx-lb.backend_pool_id

  cloud_init_vars = {
    njs_ip_address = signum(local.lnjs_count) == 0 ? null : module.lnjs-lb.private_ip_address
  }
}