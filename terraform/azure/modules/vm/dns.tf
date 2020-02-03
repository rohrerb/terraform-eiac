resource "azurerm_private_dns_a_record" "dns-a-record-ind" {
  for_each = { for i in local.items : i.key => i }

  name                  = format("%s%s%03d", var.os_code, var.instance_type, each.value.index)
  zone_name           = local.dns_zone_name
  resource_group_name = local.network_resource_group
  ttl                 = 300
  records             = azurerm_network_interface.vm_nic[each.key].private_ip_addresses
}


resource "azurerm_private_dns_a_record" "dns-a-record" {
  count               = signum(length(local.items))

  name                  = format("%s%s", var.os_code, var.instance_type)
  zone_name           = local.dns_zone_name
  resource_group_name = local.network_resource_group
  ttl                 = 300
  records             = flatten(values(azurerm_network_interface.vm_nic).*.private_ip_addresses)
}