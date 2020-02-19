
#SA Password should be changed once VM is stood up and configured.
resource "random_password" "sa_password" {
  count = signum(var.sql_config_map.deploy ? 1 : 0)

  length           = 16
  special          = false
  override_special = "!#-_=+"
}

resource "azurerm_sql_server" "sql_server" {
  count = signum(var.sql_config_map.deploy ? 1 : 0)

  name                         = lower(format("%s-%s-%s", var.dep_generic_map.full_env_code, "ss", var.sql_config_map.server_name))
  resource_group_name          = var.resource_group_name
  location                     = var.dep_generic_map.location
  version                      = "12.0"
  administrator_login          = var.sql_config_map.admin_user
  administrator_login_password = random_password.sa_password.*.result[0]
}

resource "azurerm_sql_firewall_rule" "sql_fw_rule" {
  for_each = (var.sql_config_map.deploy ? var.sql_config_map.firewall_rules : {})

  name                = each.key
  resource_group_name = var.resource_group_name
  server_name         = azurerm_sql_server.sql_server.*.name[0]
  start_ip_address    = each.value.start_ip_address
  end_ip_address      = each.value.end_ip_address
}

resource "azurerm_sql_database" "sql_db" {
  for_each = (var.sql_config_map.deploy ? var.sql_config_map.databases : {})

  name                = lower(format("%s-%s", azurerm_sql_server.sql_server.*.name[0], each.key))
  resource_group_name = var.resource_group_name
  location            = var.dep_generic_map.location
  server_name         = azurerm_sql_server.sql_server.*.name[0]

  edition                          = each.value.edition
  requested_service_objective_name = each.value.size
}


data "azurerm_subnet" "subnet" {
  for_each = (var.sql_config_map.deploy ? var.sql_config_map.subnet_vnet_access : {})

  name                 = each.key
  virtual_network_name = format("%s-net", var.dep_generic_map.full_env_code)
  resource_group_name  = var.dep_generic_map.network_resource_group
}

resource "azurerm_sql_virtual_network_rule" "sql_vnet_rule" {
  for_each = data.azurerm_subnet.subnet

  name                = format("%s-sql-vnet-rule", each.key)
  resource_group_name = var.resource_group_name
  server_name         = azurerm_sql_server.sql_server.*.name[0]
  subnet_id           = each.value.id

  ignore_missing_vnet_service_endpoint = true
}
