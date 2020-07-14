variable "create" {
  description = "Creation flag, effectively"
}

variable "resource_group_name" {
  description = "Azure resource group name"
}

variable "location" {
  description = "Location in which to deploy resources"
}

variable "target_regions" {
  type = list
  default = []
}

variable "global_image_version" {
  description = "Default version of the image to use in shared image gallery"
}

variable "gallery_name" {}

variable "image_name" {}

variable "managed_image_id" {}
