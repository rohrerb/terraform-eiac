
data "azurerm_subscription" "current" {}

data "template_file" "cloudconfig" {
  for_each = { for i in local.items : i.key => i
    if var.os_code == var.os_code_linux
  }

  template = "${file(format("%s/cloud-init/%s%s_cloudconfig.tpl", path.root, var.os_code, var.instance_type))}"

  vars = {
    //deployment_code = "${var.deployment_code}"
  }
}