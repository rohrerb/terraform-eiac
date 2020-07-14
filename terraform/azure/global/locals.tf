locals {

  full_env_code           = format("%s%s%s", lower(var.environment_code), lower(var.deployment_code), lower(var.location_code))
 
 
}
