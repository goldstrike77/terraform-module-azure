# 创建虚拟网络。
resource "azurerm_virtual_network" "virtual_network" {
  name                = "AZ-VNet-${title(var.customer)}-${title(var.environment)}"
  resource_group_name = "AZ-RG-${title(var.customer)}-${title(var.environment)}"
  address_space       = [var.virtual_network_cidr]
  dns_servers         = var.virtual_network_dns
  location            = var.location
  tags                = var.tag
}