# 创建资源组。
resource "azurerm_resource_group" "resource_group" {
  name     = var.rg_name
  location = var.location
  tags     = var.tags
}