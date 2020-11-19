# 创建虚拟网络。
resource "azurerm_virtual_network" "virtual_network" {
  count               = length(var.vnet_spec)
  name                = "AZ-VNet-${title(var.customer)}-${upper(var.vnet_spec[count.index].env)}"
  resource_group_name = "AZ-RG-${title(var.customer)}-${upper(var.vnet_spec[count.index].env)}"
  address_space       = var.vnet_spec[count.index].cidr
  dns_servers         = var.vnet_spec[count.index].dns != [] ? var.vnet_spec[count.index].dns : null
  location            = var.vnet_spec[count.index].location
  tags                = var.vnet_spec[count.index].tag
}

# 创建虚拟网络对等。
resource "azurerm_virtual_network_peering" "virtual_network_peering" {
  count                        = length(var.vnet_spec)
  name                         = "AZ-VNet-peering-to-${azurerm_virtual_network.virtual_network[1 - count.index].name}"
  resource_group_name          = "AZ-RG-${title(var.customer)}-${upper(var.vnet_spec[count.index].env)}"
  virtual_network_name         = element(azurerm_virtual_network.virtual_network.*.name, count.index)
  remote_virtual_network_id    = element(azurerm_virtual_network.virtual_network.*.id, 1 - count.index)
  allow_virtual_network_access = var.vnet_spec[count.index].allow_virtual_network_access
  allow_forwarded_traffic      = var.vnet_spec[count.index].allow_forwarded_traffic
  allow_gateway_transit        = var.vnet_spec[count.index].allow_gateway_transit
}