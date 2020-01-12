output "id" {
  # element() avoids TF warning due to the use of count in the module
  value = element(concat(azurerm_resource_group.rg.*.id, list("")), 0)
}

output "name" {
  value = format("%s-%s", upper(var.full_env_code), lower(var.name_suffix))
}

output "location" {
  # element() avoids TF warning due to the use of count in the module
  value = element(concat(azurerm_resource_group.rg.*.location, list("")), 0)
}