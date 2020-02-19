variable "dep_generic_map" {
  type = map
}

variable "resource_group_name" {
  description = "Azure resource group name"
}

variable "sql_config_map" {
  //type = map
  //default = {}
}

variable "vnet_subnets" {
  type    = list
  default = []
}