variable "name" {
  description = "Name of load balancer"
}

variable "create" {
  description = "Creation flag, effectively"
  default     = false
}

variable "resource_group_name" {
  description = "Azure resource group name"
}

variable "location" {
  description = "Location in which to deploy resources"
}

variable "default_ip_whitelist" {
  description = "List of IPs to whitelist on all RDP | SSH enabled NSG rules."
  default     = []
}

variable "apply_ssh_rule" {
  description = "Applies the default SSH rule"
  default     = false
}

variable "apply_rdp_rule" {
  description = "Applies the default RDP rule"
  default     = false
}

variable "apply_tcp_block_rule" {
  description = "Applies the default tcp block rule"
  default     = false
}

variable "apply_udp_block_rule" {
  description = "Applies the default udp block rule"
  default     = false
}

variable "full_env_code" {
  description = "Environment, Deployment, Location code"
}
