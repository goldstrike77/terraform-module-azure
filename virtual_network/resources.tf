# 创建虚拟网络。
resource "azurerm_virtual_network" "virtual_network" {
  count               = length(var.vnet_spec)
  name                = "vnet-${title(var.vnet_spec[count.index].customer)}-${upper(var.vnet_spec[count.index].env)}-${lower(var.vnet_spec[count.index].location)}"
  resource_group_name = "rg-${title(var.vnet_spec[count.index].customer)}-${upper(var.vnet_spec[count.index].env)}"
  address_space       = var.vnet_spec[count.index].cidr
  dns_servers         = var.vnet_spec[count.index].dns != [] ? var.vnet_spec[count.index].dns : null
  location            = var.vnet_spec[count.index].location
  tags                = var.vnet_spec[count.index].tag
}

# 等待资源组状态可查询。
resource "time_sleep" "wait" {
  depends_on      = [azurerm_virtual_network.virtual_network]
  create_duration = "60s"
}

# 获取对等虚拟网络编号。
data "azurerm_virtual_network" "virtual_network" {
  depends_on          = [time_sleep.wait]
  for_each            = { for s in local.vnet_flat : s.link => s if s.env_src != null }
  name                = "vnet-${title(each.value.customer_dst)}-${upper(each.value.env_dst)}-${lower(each.value.location)}"
  resource_group_name = "rg-${title(each.value.customer_dst)}-${upper(each.value.env_dst)}"
}

# 创建虚拟网络全局对等。
resource "azurerm_virtual_network_peering" "virtual_network_peering" {
  depends_on                   = [data.azurerm_virtual_network.virtual_network]
  for_each                     = { for s in local.vnet_flat : s.link => s if s.env_src != null }
  name                         = "peer-vnet-${title(each.value.customer_dst)}-${upper(each.value.env_dst)}-${lower(each.value.location)}"
  resource_group_name          = "rg-${title(each.value.customer_src)}-${upper(each.value.env_src)}"
  virtual_network_name         = "vnet-${title(each.value.customer_src)}-${upper(each.value.env_src)}-${lower(each.value.location)}"
  remote_virtual_network_id    = data.azurerm_virtual_network.virtual_network[each.key].id
  allow_virtual_network_access = each.value.allow_virtual_network_access
  allow_forwarded_traffic      = each.value.allow_forwarded_traffic
  allow_gateway_transit        = each.value.allow_gateway_transit
}