variable "name" {
  description = "Name of load balancer"
}


variable "sku" {
  description = "Azure SKU - {basic, standard}"
  default     = "Basic"
}

variable "resource_group_name" {
  description = "Azure resource group name"
}

variable "subnet_id" {
  description = "Azure subnet id"
}

variable "probe_port" {
  description = "Probe port."
}

variable "private_ip_address_allocation" {
  default = "dynamic"
}

variable "create" {
  default = false
}

variable "is_public" {
  default = false
}

variable "rules_map" {
  type    = map
  default = {}
  /*
    {
     }
*/
}

variable "dep_generic_map" {
  type    = map
  default = {}
}
