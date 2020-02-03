

resource "azurerm_lb" "lb" {
  name                = format("%s%s-%s", var.full_env_code, var.name, "lb")
  count               = (local.enable ? 1 : 0)
  sku                 = var.sku
  resource_group_name = var.resource_group_name
  location            = var.location

  dynamic "frontend_ip_configuration" {
    for_each = { for o in range(0, 1) : o => o
    if var.is_public }

    content {
      name                      = local.frontend_ip_configuration_name
      public_ip_address_id      = azurerm_public_ip.lb-pip.*.id[0]
    }
  }

  dynamic "frontend_ip_configuration" {
    for_each = { for o in range(0, 1) : o => o
    if !var.is_public }

    content {
      name                          = local.frontend_ip_configuration_name
      subnet_id                     = var.subnet_id
      private_ip_address_allocation = var.private_ip_address_allocation
    }
  }
}

resource "azurerm_public_ip" "lb-pip" {
  count               = (var.is_public ? 1 : 0)
  name                = format("%s%s-%s", var.full_env_code, var.name, "lb-pip")
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = var.sku

  domain_name_label = format("%s%s-%s", var.full_env_code, var.name, "lb-pip")
}


resource "azurerm_lb_backend_address_pool" "backend_address_pool" {
  name                = format("%s-%s", var.name, "pool")
  count               = (local.enable ? 1 : 0)
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.lb.*.id[0]
}

resource "azurerm_lb_probe" "lb_probe" {
  name                = format("%s-%s", var.name, "probe")
  count               = (local.enable ? 1 : 0)
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.lb.*.id[0]
  port                = var.probe_port
  interval_in_seconds = 5
}

resource "azurerm_lb_rule" "lb_rule" {
  for_each = (local.enable ? var.rules_map : {})

  name                           = each.key
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.lb.*.id[0]
  protocol                       = lookup(each.value, "protocol", "TCP")
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = local.frontend_ip_configuration_name
  backend_address_pool_id        = azurerm_lb_backend_address_pool.backend_address_pool.*.id[0]
  probe_id                       = azurerm_lb_probe.lb_probe.*.id[0]
  enable_floating_ip             = tobool(lookup(each.value, "enable_floating_ip", false))
  load_distribution              = lookup(each.value, "load_distribution", "Default")
  idle_timeout_in_minutes        = tonumber(lookup(each.value, "idle_timeout_in_minutes", 4))
}
