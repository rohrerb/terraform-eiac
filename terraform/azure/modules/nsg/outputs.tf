output "name" {
  # element() avoids TF warning due to the use of count in the module
  value = "${element(concat(azurerm_network_security_group.nsg.*.name, list("")), 0)}"
}

output "id" {
  # element() avoids TF warning due to the use of count in the module
  value = "${element(concat(azurerm_network_security_group.nsg.*.id, list("")), 0)}"
}
