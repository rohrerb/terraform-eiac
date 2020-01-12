variable "full_env_code" {
  description = "Environment, Deployment, Location code"
}

variable "name_suffix" {
  description = "Name to append to the full_env_code. "
}

variable "resource_group_name" {
  description = "Azure resource group name"
}

variable "dns_prefix" {
}

variable "service_principal_enddate" {
}

variable "network_plugin" {
  type = string
}

variable "agent_pools" {
  default = {}
  type    = map
}

variable "location" {
  description = "Location in which to deploy resources"
}
