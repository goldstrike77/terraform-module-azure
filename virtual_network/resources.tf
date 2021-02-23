# 创建虚拟网络。
resource "azurerm_virtual_network" "virtual_network" {
  name                = var.vnet_name
  resource_group_name = var.rg_name
  address_space       = lookup(var.vnet_spec, "cidr", ["10.0.0.0/16"])
  dns_servers         = lookup(var.vnet_spec, "dns", null)
  location            = var.location
  tags                = var.tags
}

# 等待资源组状态可查询。
resource "time_sleep" "wait" {
  depends_on      = [azurerm_virtual_network.virtual_network]
  create_duration = "60s"
}

# 获取虚拟中心编号。
data "azurerm_virtual_hub" "virtual_hub" {
  depends_on          = [time_sleep.wait]
  count               = var.vnet_conn == "vhub" ? 1 : 0  
  name                = var.vhub_name
  resource_group_name = var.rg_name
}

# 创建虚拟中心连接。
resource "azurerm_virtual_hub_connection" "virtual_hub_connection" {
  depends_on                = [data.azurerm_virtual_hub.virtual_hub]
  count                     = var.vnet_conn == "vhub" ? 1 : 0
  name                      = "${var.vnet_name}-to-${var.vhub_name}"
  virtual_hub_id            = data.azurerm_virtual_hub.virtual_hub[0].id
  remote_virtual_network_id = azurerm_virtual_network.virtual_network.id
}