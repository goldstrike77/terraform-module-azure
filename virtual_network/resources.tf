# 创建虚拟网络。
resource "azurerm_virtual_network" "virtual_network" {
  for_each            = { for s in var.vnet_spec : format("%s-%s-%s", s.customer, s.env, s.location) => s }
  name                = "vnet-${title(each.value.customer)}-${upper(each.value.env)}-${lower(each.value.location)}"
  resource_group_name = "rg-${title(each.value.customer)}-${upper(each.value.env)}"
  address_space       = each.value.cidr
  dns_servers         = each.value.dns != [] ? each.value.dns : null
  location            = each.value.location
  tags                = each.value.tag
}

# 等待资源组状态可查询。
resource "time_sleep" "wait" {
  depends_on      = [azurerm_virtual_network.virtual_network]
  create_duration = "60s"
}

# 获取虚拟中心编号。
data "azurerm_virtual_hub" "virtual_hub" {
  depends_on          = [time_sleep.wait]
  name                = "vhub-${title(var.customer)}-${upper(var.env)}"
  resource_group_name = "rg-${title(var.customer)}-${upper(var.env)}"
}

# 创建虚拟中心连接。
resource "azurerm_virtual_hub_connection" "virtual_hub_connection" {
  depends_on                = [data.azurerm_virtual_hub.virtual_hub]
  for_each                  = { for s in var.vnet_spec : format("%s-%s-%s", s.customer, s.env, s.location) => s if var.vnet_conn == "vhub" }
  name                      = "vhub-conn-${title(each.value.customer)}-${upper(each.value.env)}"
  virtual_hub_id            = data.azurerm_virtual_hub.virtual_hub.id
  remote_virtual_network_id = azurerm_virtual_network.virtual_network[each.key].id
}

# 获取对等虚拟网络编号。
data "azurerm_virtual_network" "virtual_network" {
  depends_on          = [time_sleep.wait]
  for_each            = { for s in local.vnet_flat : s.link => s if s.env_src != null }
  name                = "vnet-${title(each.value.customer_dst)}-${upper(each.value.env_dst)}-${lower(each.value.location)}"
  resource_group_name = "rg-${title(each.value.customer_dst)}-${upper(each.value.env_dst)}"
}

# 创建虚拟网络全局显式对等。
resource "azurerm_virtual_network_peering" "virtual_network_peering" {
  depends_on                   = [data.azurerm_virtual_network.virtual_network]
  for_each                     = { for s in local.vnet_flat : s.link => s if s.env_src != null && var.vnet_conn == "peering" }
  name                         = "peer-vnet-${title(each.value.customer_dst)}-${upper(each.value.env_dst)}-${lower(each.value.location)}"
  resource_group_name          = "rg-${title(each.value.customer_src)}-${upper(each.value.env_src)}"
  virtual_network_name         = "vnet-${title(each.value.customer_src)}-${upper(each.value.env_src)}-${lower(each.value.location)}"
  remote_virtual_network_id    = data.azurerm_virtual_network.virtual_network[each.key].id
  allow_virtual_network_access = each.value.allow_virtual_network_access
  allow_forwarded_traffic      = each.value.allow_forwarded_traffic
  allow_gateway_transit        = each.value.allow_gateway_transit
}