# 创建恢复服务保管库。
resource "azurerm_recovery_services_vault" "recovery_services_vault" {
  name                = "rsv-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}"
  location            = var.location
  resource_group_name = "rg-${title(var.customer)}-${upper(var.env)}"
  sku                 = "Standard"
  soft_delete_enabled = false
  tags                = var.tag
}