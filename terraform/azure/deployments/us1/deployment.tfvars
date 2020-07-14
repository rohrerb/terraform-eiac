subscription_id = ""

is_azure_government = true
enable_remote_state = false

global_image_version = "1.0.0"

environment_code        = "d"
deployment_code         = "us1"
location_code           = "va1"
location_code_secondary = "tx1"

location           = "USGov Virginia"
location_secondary = "USGov Texas"

platform_fault_domain_count = 2

network_octets           = "10.1"
network_octets_secondary = "10.2"

enable_secondary         = false
enable_recovery_services = false

dns_servers = []
enable_log_analytics = true
enable_bastion     = true

vm_instance_maps = {
  #Squid Proxy
  lsqd = { count = 1, size = "Standard_D2s_v3", os_disk_size = 30, data_disk_count = 0, data_disk_size = 0, enable_recovery = false, enable_public_ip = false, enable_vm_diagnostics = false }

  #Nginx
  lngx = { count = 0, size = "Standard_D2s_v3", os_disk_size = 30, data_disk_count = 0, data_disk_size = 0, enable_recovery = false, enable_public_ip = false, enable_vm_diagnostics = false }

  #NodeJS
  lnjs = { count = 1, size = "Standard_D2s_v3", os_disk_size = 30, data_disk_count = 0, data_disk_size = 0, enable_recovery = false, enable_public_ip = false, enable_vm_diagnostics = false }
}

sql_config_map = {
  myapp = {
    deploy      = true
    server_name = "main"
    admin_user  = "sadmin"
    subnet_vnet_access = {
      app = {}
    }
    firewall_rules = {}
    databases = {
      main = { edition = "Standard", size = "S0" }
    }
  }
}