resource "azurerm_private_dns_a_record" "dns-a-record" {
  count = (local.enable && ! var.is_public ? 1 : 0)

  name                = format("%s-%s", var.name, "lb")
  zone_name           = local.dns_zone_name
  resource_group_name = local.network_resource_group
  ttl                 = 300
  records             = azurerm_lb.lb.*.private_ip_address
}