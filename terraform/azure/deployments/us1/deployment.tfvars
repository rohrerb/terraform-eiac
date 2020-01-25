subscription_id = ""

is_azure_government = true
enable_remote_state = false

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

vm_instance_maps = {
  lngx = { count = 0, size = "Standard_D2s_v3", os_disk_size = 30, data_disk_count = 0, data_disk_size = 0, enable_public_ip = true, enable_recovery = false }
  lsql = { count = 0, size = "Standard_D2s_v3", os_disk_size = 30 }
}
