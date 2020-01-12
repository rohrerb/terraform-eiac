
variable "resource_group_name" {
  description = "Azure resource group name"
}

variable "location" {
  description = "Location in which to deploy resources"
}

variable "rules_map" {
  type    = map
  default = {}
  /*
    {
        rule1 = {priority = 105, direction = "Inbound", access = "Allow", protocol = "TCP", source_port_range = "*", destination_port_range = "*",source_address_prefix = "*", destination_address_prefix = "*"  } ,
        rule2 = {priority = 105, direction = "Outbound", access = "Deny", protocol = "TCP", source_port_range = "*", destination_port_range = "*",source_address_prefix = "*", destination_address_prefix = "*"  }    
    }
*/
}

variable "create" {
  description = "Creation flag, effectively"
  default     = false
}

variable "network_security_group_name" {
  description = "The name of the Network Security Group that we want to attach the rule to."
}
