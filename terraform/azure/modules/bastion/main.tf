
resource "azurerm_bastion_host" "bastion" {
  count = signum(var.create ? 1 : 0)

  name                = format("%s-bastion", var.full_env_code)
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.bastion-pip.*.id[0]
  }
}

resource "azurerm_public_ip" "bastion-pip" {
  count = signum(var.create ? 1 : 0)

  name                = format("%s-bastion-pip", var.full_env_code)
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}