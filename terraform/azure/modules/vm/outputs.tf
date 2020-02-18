
output "private_ip_address" {
  value = {
    for v in azurerm_network_interface.vm_nic :
    v.name => v.private_ip_address
  }
}


output "dns_all" {
  value = element(concat(azurerm_private_dns_a_record.dns-a-record.*.name, list("")), 0)
}
