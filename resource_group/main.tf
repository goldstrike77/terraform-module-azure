# 创建资源组。
resource "azurerm_resource_group" "resource_group" {
  count    = length(var.rg_spec)
  name     = "AZ-RG-${title(var.customer)}-${upper(var.rg_spec[count.index].env)}"
  location = var.rg_spec[count.index].location
  tags     = var.rg_spec[count.index].tag
}