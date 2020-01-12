

variable "full_env_code" {
  description = "Environment, Deployment, Location code"
}

variable "sku" {
  default = "Standard"
}

variable "resource_group_name" {
  description = "Azure resource group name"
}

variable "resource_group_name_for_recoverycache" {
  description = "Azure resource group name"
}

variable "location_primary" {
  description = "Location Primary"
}

variable "location_secondary" {
  description = "Location Secondary"
}

variable "recovery_point_retention_in_minutes" {
  default = 1440
}

variable "application_consistent_snapshot_frequency_in_minutes" {
  default = 240
}

variable "network_id_primary" {
  description = "Primary Network Id"
}

variable "network_id_secondary" {
  description = "Primary Network Id"
}

variable "create" {
  description = "Creation Flag"
  type        = bool
  default     = false
}



 