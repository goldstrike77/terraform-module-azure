# 创建资源组。
resource "azurerm_resource_group" "resource_group" {
  name     = "AZ-RG-${title(var.customer)}-${title(var.environment)}"
  location = var.location
  tags     = var.tag
}