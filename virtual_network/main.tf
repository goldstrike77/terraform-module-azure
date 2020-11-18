# 创建虚拟网络。
resource "azurerm_virtual_network" "virtual_network" {
  for_each            = var.vnet_spec
  name                = "AZ-VNet-${title(var.customer)}-${upper(each.key)}"
  resource_group_name = "AZ-RG-${title(var.customer)}-${upper(each.key)}"
  address_space       = each.value.cidr
  dns_servers         = each.value.dns != [] ? each.value.dns : null
  location            = each.value.location
  tags                = each.value.tag
}