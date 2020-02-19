locals {

  enable                         = var.create
  frontend_ip_configuration_name = "frontend"
  location                       = var.dep_generic_map.location
  location_secondary             = var.dep_generic_map.location_secondary
  full_env_code                  = var.dep_generic_map.full_env_code
  dns_zone_name                  = var.dep_generic_map.dns_zone_name
  network_resource_group         = var.dep_generic_map.network_resource_group
}
