
resource "azurerm_virtual_machine_extension" "extension" {
  for_each = { for vm in azurerm_virtual_machine.vm : vm.name => vm
    if local.enable_log_analytics 
  }

  name                 = "LogAnalyticsMonitoring"
  virtual_machine_id   = each.value.id
  publisher            = "Microsoft.EnterpriseCloud.Monitoring"
  type                 = var.os_code == var.os_code_linux ? "OmsAgentForLinux" : "MicrosoftMonitoringAgent"
  type_handler_version = var.os_code == var.os_code_linux ? "1.12" : "1.0"

  settings = jsonencode({ workspaceId = local.log_analytics_worspace_id })

  protected_settings = jsonencode(
    {
      workspaceKey = local.log_analytics_worspace_key,
      vmResourceId = each.value.id
    }
  )
}
