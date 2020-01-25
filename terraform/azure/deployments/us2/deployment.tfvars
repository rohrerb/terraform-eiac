subscription_id     = ""
enable_remote_state = false

environment_code        = "d"
deployment_code         = "us2"
location_code           = "ea1"
location_code_secondary = "we1"

location           = "East US"
location_secondary = "West US"

network_octets           = "10.3"
network_octets_secondary = "10.4"

enable_secondary         = false
enable_recovery_services = false

enable_bastion     = true
deploy_using_zones = true

dns_servers = []

vm_instance_maps = {
  lngx = { count = 0, size = "Standard_D2s_v3", os_disk_size = 30, enable_recovery = false, enable_public_ip = false, enable_vm_diagnostics = false }
  lsql = { count = 0, size = "Standard_D2s_v3", os_disk_size = 30, data_disk_count = 0, data_disk_size = 5, enable_public_ip = false }
}


