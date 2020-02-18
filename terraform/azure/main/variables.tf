variable "environment_code" {
  description = "Environment code"
}

variable "deployment_code" {
  description = "Deployment code"
}

variable "location_code" {
  description = "Location code"
}

variable "location_code_secondary" {
  description = "Location code secondary"
}

variable "location" {
  description = "Location in which to deploy resources"
}

variable "location_secondary" {
  description = "Location in which to deploy resources in a secondary region"
}

variable "network_octets" {
  description = "First two octects of data center subnet e.g. the X.Y in X.Y.0.0"
}

variable "network_octets_secondary" {
  description = "First two octects of data center subnet e.g. the X.Y in X.Y.0.0"
}

variable "subscription_id" {}

variable "subnet" {
  type = map

  default = {
    "dmz"                = { subnet_octet = "0", service_endpoints = [] }
    "services"           = { subnet_octet = "1", service_endpoints = [] }
    "data"               = { subnet_octet = "2", service_endpoints = [] }
    "management"         = { subnet_octet = "3", service_endpoints = [] }
    "app"                = { subnet_octet = "4", service_endpoints = ["Microsoft.Sql"] }
    "AzureBastionSubnet" = { subnet_octet = "9", service_endpoints = [] }
  }
}

variable "dns_servers" {
  description = "Name server IP list"
  type        = list
  default     = []
}

variable "os_code_linux" {
  description = ""
  default     = "l"
}

variable "os_code_windows" {
  description = ""
  default     = "w"
}

variable "is_azure_government" {
  default = false
}

variable "enable_remote_state" {
  default = false
}

variable "enable_secondary" {
  default = false
}

variable "enable_log_analytics" {
  default = false
}

variable "vm_instance_maps" {
  type = map
}

variable "storage_type_default" {
  description = "Default storage type if not specified in storage_account_type"
  default     = "Premium_LRS"
}

variable "platform_fault_domain_count" {
  default = 3
}

variable "enable_recovery_services" {
  type    = bool
  default = false
}

variable "enable_bastion" {
  type    = bool
  default = false
}

variable "deploy_using_zones" {
  type        = bool
  default     = false
  description = "If Enabled the VMs will be spread accros Availability Zones vs Availability Sets."
}

variable "ssh_key_path" {
  type    = string
  default = "~/.ssh/id_rsa.pub"
}

variable "admin_username" {
  description = "Window / Linux Administrator account (can't be administrator)"
  default     = "cadmin"
}

variable "log_analytics_location_override" {
  description = "Alternate location to deploy log analytics if not available in primary region."
  default     = null
}


variable "sql_config_map" {
  type    = map
  default = {}
}
