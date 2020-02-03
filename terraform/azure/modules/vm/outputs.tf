
output "private_ip_address" {
  value = { 
      for v in azurerm_network_interface.vm_nic :
        v.name => v.private_ip_address
  }
}

