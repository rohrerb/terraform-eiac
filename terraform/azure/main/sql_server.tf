
locals {
  main_sql_config_map = lookup(var.sql_config_map, "myapp")
}


module "sql_server-main" {
  source = "../modules/sql_server"

  dep_generic_map = local.dep_generic_map
  sql_config_map  = local.main_sql_config_map

  resource_group_name = module.rg-data.name
  vnet_subnets        = [local.subnet_id_data]
}
