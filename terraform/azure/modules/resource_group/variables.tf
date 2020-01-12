variable "full_env_code" {
  description = "Environment, Deployment, Location code"
}

variable "location" {
  description = "Location in which to deploy resources"
}

variable "destroy_resource_groups" {
  description = "If enabled - it will destroy all resouce groups except the state resource group"
  default     = false
}

variable "create" {
  description = "Creation Flag"
  type        = bool
  default     = false
}

variable "enable_delete_lock" {
  description = "Flag to enable / disable resource group lock"
}

variable "name_suffix" {
  description = "Name to append to the full_env_code. "
}

variable "tags" {
  default = {}
}
