
resource "azurerm_public_ip" "lb-pip" {
  count               = (var.create ? 1 : 0)
  name                = format("%s%s-%s", var.full_env_code, var.name, "lb-pip")
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = var.sku

  domain_name_label = format("%s%s-%s", var.full_env_code, var.name, "lb-pip")
}

resource "azurerm_lb" "lb" {
  name                = format("%s%s-%s", var.full_env_code, var.name, "lb")
  count               = (var.create ? 1 : 0)
  sku                 = var.sku
  resource_group_name = var.resource_group_name
  location            = var.location

  frontend_ip_configuration {
    name                 = "loadBalancerFrontEnd"
    public_ip_address_id = azurerm_public_ip.lb-pip.*.id[0]
  }
}

resource "azurerm_lb_backend_address_pool" "backend_address_pool" {
  name                = format("%s-%s", var.name, "pool")
  count               = (var.create ? 1 : 0)
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.lb.*.id[0]
}

resource "azurerm_lb_probe" "lb_probe" {
  name                = format("%s-%s", var.name, "probe")
  count               = (var.create ? 1 : 0)
  resource_group_name = var.resource_group_name
  loadbalancer_id     = azurerm_lb.lb.*.id[0]
  port                = var.probe_port
  interval_in_seconds = 5
}

resource "azurerm_lb_rule" "lb_rule" {
  name                           = format("%s-%s", var.name, "rule")
  count                          = (var.create ? 1 : 0)
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.lb.*.id[0]
  protocol                       = "TCP"
  frontend_port                  = var.port
  backend_port                   = var.port
  frontend_ip_configuration_name = "loadBalancerFrontEnd"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.backend_address_pool.*.id[0]
  probe_id                       = azurerm_lb_probe.lb_probe.*.id[0]
  enable_floating_ip             = var.enable_floating_ip
  load_distribution              = var.load_distribution
  idle_timeout_in_minutes        = var.timeout
}
