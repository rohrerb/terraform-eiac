resource "local_file" "packer_config" {
    content     = jsonencode(
        {
            "subscription_id" = var.subscription_id,
            "location" = var.location,
            "cloud_environment_name" = (var.is_azure_government ? "USGovernment" : "Public"),
            "resource_group" = module.rg-packer.name        
        })
    filename = format("%s/../packer/deployments/%s.json",path.module,var.deployment_code)
}
