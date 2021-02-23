# 创建恢复服务保管库。
resource "azurerm_recovery_services_vault" "recovery_services_vault" {
  name                = var.rsv_name
  location            = var.location
  resource_group_name = var.rg_name
  sku                 = "Standard"
  soft_delete_enabled = false
  tags                = var.tags
}