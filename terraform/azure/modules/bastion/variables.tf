variable "full_env_code" {
  description = "Environment, Deployment, Location code"
}

variable "resource_group_name" {
  description = "Azure resource group name"
}

variable "location" {
  description = "Location in which to deploy resources"
}

variable "create" {
  description = "Creation Flag"
  type        = bool
  default     = false
}

variable "subnet_id" {
  description = "Subnet to enable the bastion host on."
}