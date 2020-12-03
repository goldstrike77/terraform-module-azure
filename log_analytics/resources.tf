# 创建日志分析工作区。
resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  name                       = "log-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}"
  location                   = var.location
  resource_group_name        = "rg-${title(var.customer)}-${upper(var.env)}"
  sku                        = "PerGB2018"
  retention_in_days          = lookup(var.log_spec, "retention_in_days", 180)
  internet_ingestion_enabled = lookup(var.log_spec, "internet_ingestion_enabled", false)
  internet_query_enabled     = lookup(var.log_spec, "internet_query_enabled", false)
  tags                       = var.tag
}