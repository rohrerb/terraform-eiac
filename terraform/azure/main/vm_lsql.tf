locals {
  lsql_instance_map = lookup(var.vm_instance_maps, "lsql")
  lsql_count        = lookup(local.lsql_instance_map, "count", 0)
}

module "lsql-nsg" {
  source               = "../modules/nsg"
  create               = (signum(local.lsql_count) == 0 ? false : true)
  full_env_code        = local.full_env_code
  name                 = "lsql-nsg"
  location             = var.location
  resource_group_name  = module.rg-data.name
  apply_ssh_rule       = false
  default_ip_whitelist = local.default_ip_whitelist
}


module "lsql-nsg-rules" {
  source                      = "../modules/nsg_rule"
  create                      = (signum(local.lsql_count) == 0 ? false : true)
  resource_group_name         = module.rg-data.name
  network_security_group_name = module.lsql-nsg.name
  location                    = var.location
  rules_map = {
    sql_inbound = { priority = 110, direction = "Inbound", access = "Allow", protocol = "TCP", destination_port_range = "1443" }
  }
}

#SA Password should be changed once VM is stood up and configured.
resource "random_password" "lsql_sa_password" {
  count = signum(length(local.lsql_instance_map) > 0 ? 1 : 0)

  length  = 16
  special = true
}

module "lsql" {
  source          = "../modules/vm"
  vm_generic_map  = local.vm_generic_map
  vm_instance_map = local.lsql_instance_map

  os_code                = var.os_code_linux
  instance_type          = "sql"
  number_of_vms_in_avset = local.lsql_count

  resource_group_name = module.rg-data.name
  os_disk_image_id    = data.azurerm_image.ubuntu.id

  subnet_id                 = azurerm_subnet.subnet["Data"].id
  network_security_group_id = local.lsql_count == 0 ? "" : module.lsql-nsg.id

  cloud_init_vars = {
      sa_password = random_password.lsql_sa_password.*.result[0]
  }
}
