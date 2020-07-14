variable "environment_code" {
  description = "Environment code"
}

variable "deployment_code" {
  description = "Deployment code"
}

variable "location_code" {
  description = "Location code"
}

variable "location" {
  description = "Location in which to deploy resources"
}

variable "subscription_id" {}


variable "is_azure_government" {
  default = false
}

variable "enable_remote_state" {
  default = false
}

variable "image_target_regions" {
  type = list
  default = []
}

variable "deploy_shared_image_gallery" {
  default = false
}

variable "global_image_version" {
  description = "Default version of the image to use in shared image gallery"
}
