# 创建虚拟网络。
resource "azurerm_virtual_network" "virtual_network" {
  count               = length(var.vnet_spec)
  name                = "vnet-${title(var.customer)}-${upper(var.vnet_spec[count.index].env)}-${lower(var.vnet_spec[count.index].location)}"
  resource_group_name = "rg-${title(var.customer)}-${upper(var.vnet_spec[count.index].env)}"
  address_space       = var.vnet_spec[count.index].cidr
  dns_servers         = var.vnet_spec[count.index].dns != [] ? var.vnet_spec[count.index].dns : null
  location            = var.vnet_spec[count.index].location
  tags                = var.vnet_spec[count.index].tag
}

# 创建虚拟网络全局对等。
resource "azurerm_virtual_network_peering" "virtual_network_peering" {
  count                        = length(var.vnet_spec)
  name                         = "peer-${azurerm_virtual_network.virtual_network[count.index + 1 != length(var.vnet_spec) ? count.index + 1 : 0].name}"
  resource_group_name          = "rg-${title(var.customer)}-${upper(var.vnet_spec[count.index].env)}"
  virtual_network_name         = element(azurerm_virtual_network.virtual_network.*.name, count.index)
  remote_virtual_network_id    = element(azurerm_virtual_network.virtual_network.*.id, count.index + 1 != length(var.vnet_spec) ? count.index + 1 : 0)
  allow_virtual_network_access = var.vnet_spec[count.index].allow_virtual_network_access
  allow_forwarded_traffic      = var.vnet_spec[count.index].allow_forwarded_traffic
  allow_gateway_transit        = var.vnet_spec[count.index].allow_gateway_transit
}