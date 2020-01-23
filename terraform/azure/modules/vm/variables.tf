

variable "os_code" {
  description = "os code: l or w"
}

variable "enable_internal_lb" {
  description = "Enable Internal Load Balancer"
  default     = false
}

variable "backend_address_pool_id_internal" {
  description = "Backend Address pool for internal LB"
  default     = ""
}

variable "enable_external_lb" {
  description = "Enable External Load Balancer"
  default     = false
}

variable "backend_address_pool_id_external" {
  description = "Backend Address pool for external LB"
  default     = ""
}

variable "storage_type" {
  description = "Storage type used for all disks"
  default     = "Premium_LRS"
}

variable "instance_type" {}

variable "subnet_id" {}


variable "resource_group_name" {}

variable "availability_set_id" {
  description = "Availability set for instances."
  default     = ""
}

variable "os_disk_image_id" {
  description = "OS disk image ID for this subscription"
}

variable "ip_forwarding" {
  description = "Enable IP forwarding (OVP, VPN, ...)"
  default     = false
}

variable "number_of_vms_in_avset" {
  description = "Number of VMs in a AVset"
}

variable "platform_fault_domain_count" {
  description = "Fault Domain Count for Azure"
  default     = 3
}

variable "admin_username" {
  description = "Window / Linux Administrator account (can't be administrator)"
  default     = "cadmin"
}

variable "vm_instance_map" {
  description = "Map of instance type settings"
  type        = map
}

variable "lb_pools_ids" {
  type    = list
  default = []
}

variable "network_security_group_id" {
  default = ""
}

variable "os_code_linux" {
  description = ""
  default     = "l"
}

variable "os_code_windows" {
  description = ""
  default     = "w"
}

variable "vm_generic_map" {
  type    = map
  default = {}
}

variable "number_of_zones" {
  default = 3
}

variable "cloud_init_vars" {
  type = map
  default = null
}