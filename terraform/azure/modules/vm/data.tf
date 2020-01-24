
data "azurerm_subscription" "current" {}

data "template_file" "cloudconfig" {
  for_each = { for i in local.items : i.key => i
    if var.os_code == var.os_code_linux &&
    fileexists(local.cloud_init_file)
  }

  template = "${file(local.cloud_init_file)}"
  vars = local.cloud_init_vars  
}
