resource "local_file" "packer_config" {
  content = jsonencode(
    {
      "subscription_id"                     = var.subscription_id
      "location"                            = var.location
      "cloud_environment_name"              = (var.is_azure_government ? "USGovernment" : "Public")
      "resource_group"                      = module.rg-global.name
  })
  filename = format("%s/../packer/deployments/%s%s.json", path.module, var.environment_code, var.deployment_code)
}
