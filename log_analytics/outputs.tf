output "log_analytics_workspace_primary_shared_key" {
  value = formatlist(
    "%s = %s", 
    (regex(".*/(.*)", azurerm_log_analytics_workspace.log_analytics_workspace.id)),
    (azurerm_log_analytics_workspace.log_analytics_workspace.primary_shared_key)
  )
}