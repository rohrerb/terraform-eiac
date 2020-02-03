locals {
  lnjs_instance_map = lookup(var.vm_instance_maps, "lnjs")
  lnjs_count        = lookup(local.lnjs_instance_map, "count", 0)
}

module "lnjs-nsg" {
  source               = "../modules/nsg"
  create               = (signum(local.lnjs_count) == 0 ? false : true)
  full_env_code        = local.full_env_code
  name                 = "lnjs-nsg"
  location             = var.location
  resource_group_name  = module.rg-app.name
  apply_ssh_rule       = false
  default_ip_whitelist = local.default_ip_whitelist
}

module "lnjs-nsg-rules" {
  source                      = "../modules/nsg_rule"
  create                      = (signum(local.lnjs_count) == 0 ? false : true)
  resource_group_name         = module.rg-app.name
  network_security_group_name = module.lnjs-nsg.name
  location                    = var.location
  rules_map = {
    http_inbound   = { priority = 150, direction = "Inbound", access = "Allow", protocol = "TCP", destination_port_range = "3000" },
  }
}

module "lnjs-lb" {
  source              = "../modules/lb"
  name                = "lnjs"
  full_env_code       = local.full_env_code
  create              = (signum(local.lnjs_count) == 0 ? false : true)
  is_public           = false
  sku                 = "Standard"
  location            = var.location
  resource_group_name = module.rg-app.name
  subnet_id           = azurerm_subnet.subnet["app"].id
  probe_port          = 3000

  rules_map = {
    http_rule = { protocol = "TCP", frontend_port = 3000, backend_port = 3000, public_frontend = false }
  }
}

module "lnjs" {
  source = "../modules/vm"

  vm_generic_map  = local.vm_generic_map
  vm_instance_map = local.lnjs_instance_map

  os_code                = var.os_code_linux
  instance_type          = "njs"
  number_of_vms_in_avset = local.lnjs_count
  resource_group_name    = module.rg-app.name
  os_disk_image_id       = data.azurerm_image.ubuntu.id

  subnet_id                 = azurerm_subnet.subnet["app"].id
  network_security_group_id = local.lnjs_count == 0 ? "" : module.lnjs-nsg.id

  enable_internal_lb               = local.lnjs_count == 0 ? false : true
  backend_address_pool_id_internal = module.lnjs-lb.backend_pool_id

  cloud_init_vars = {
    admin_username = var.admin_username
    sql_ip_address = signum(local.lsql_count) == 0 ? null : module.lsql-lb.private_ip_address
    sql_sa_password = signum(local.lsql_count) == 0 ? null : random_password.lsql_sa_password.*.result[0]
  }
}