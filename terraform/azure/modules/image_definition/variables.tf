variable "name" {
}

variable "create" {
  default = false
}

variable "resource_group_name" {
  description = "Azure resource group name"
}

variable "location" {
  description = "Location in which to deploy resources"
}

variable "gallery_name" {}

variable "os_type" {}

variable "offer" {}

variable "sku" {}
