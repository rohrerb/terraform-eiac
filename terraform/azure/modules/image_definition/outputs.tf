output "name" {
  value = azurerm_shared_image.image.*.name[0]
}

output "location" {
  value = azurerm_shared_image.image.*.location[0]
}
