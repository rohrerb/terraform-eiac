

//Exmple
locals {

}

resource "azuread_application" "aks_app" {
  name                       = format("%s-%s-msi", upper(var.full_env_code), lower(var.name_suffix))
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = true
}

resource "azuread_service_principal" "aks_sp" {
  application_id = "${azuread_application.aks_app.application_id}"
}

resource "random_password" "aks_sp_pwd" {
  length  = 32
  special = true
}

resource "azuread_service_principal_password" "aks_sp_ad" {
  service_principal_id = azuread_service_principal.aks_sp.id
  value                = random_password.aks_sp_pwd.result
  end_date             = var.service_principal_enddate
}

resource "azurerm_kubernetes_cluster" "aks-cluster" {
  name                = format("%s-%s", upper(var.full_env_code), lower(var.name_suffix))
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix


  dynamic "agent_pool_profile" {
    iterator = pool
    for_each = var.agent_pools
    content {
      name            = pool.key
      count           = pool.value.count
      vm_size         = pool.value.vm_size
      os_type         = pool.value.os_type
      os_disk_size_gb = pool.value.os_disk_size_gb
      vnet_subnet_id  = pool.value.vnet_subnet_id
      type            = pool.value.type
    }
  }

  network_profile {
    network_plugin = var.network_plugin
  }

  service_principal {
    client_id     = azuread_service_principal.aks_sp.application_id
    client_secret = random_password.aks_sp_pwd.result
  }

}
