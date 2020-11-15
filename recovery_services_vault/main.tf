# 创建恢复服务保管库。
resource "azurerm_recovery_services_vault" "recovery_services_vault" {
  name                = "AZ-RSV-${title(var.customer)}-${title(var.environment)}"
  location            = var.location
  resource_group_name = "AZ-RG-${title(var.customer)}-${title(var.environment)}"
  sku                 = "Standard"
  soft_delete_enabled = false
  tags                = var.tag
}