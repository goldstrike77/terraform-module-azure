# 创建资源组。
resource "azurerm_resource_group" "resource_group" {
  for_each = var.rg_spec
  name     = "AZ-RG-${title(var.customer)}-${upper(each.key)}"
  location = each.value.location
  tags     = each.value.tag
}