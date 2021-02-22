# 创建资源组。
resource "azurerm_resource_group" "resource_group" {
  count    = length(var.rg_spec)
  name     = var.name
  location = var.location
  tags     = var.tag
}