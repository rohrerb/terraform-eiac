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

variable "location" {
  description = "Location in which to deploy resources"
}

variable "subnet_id" {
  description = "Azure subnet id"
}

variable "probe_port" {
  description = "Probe port."
}

/*
variable "port" {
  description = "Port for both front and back ends"
}
variable "enable_floating_ip" {
  description = "Floating IP / DSR boolean"
  default     = false
}

variable "load_distribution" {
  description = "For managing load balancing type: { Default, SourceIP, SourceIPProtocol }"
  default     = "Default"
}

variable "timeout" {
  description = "Timeout (default is 4 minutes, max is 30 minutes)"
  default     = 4
}

variable "protocol" {
  description = "Protocol (All Tcp Udp)"
  default     = "TCP"
}*/

variable "full_env_code" {
  description = "Environment, Deployment, Location code"
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
