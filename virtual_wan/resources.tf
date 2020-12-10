# 创建虚拟广域网。
resource "azurerm_virtual_wan" "virtual_wan" {
  name                           = "vwan-${title(var.customer)}-${upper(var.env)}"
  resource_group_name            = "rg-${title(var.customer)}-${upper(var.env)}"
  type                           = lookup(var.vwan_spec, "type", "Standard")
  disable_vpn_encryption         = lookup(var.vwan_spec, "disable_vpn_encryption", false)
  allow_branch_to_branch_traffic = lookup(var.vwan_spec, "allow_branch_to_branch_traffic", true)
  location                       = var.location
  tags                           = var.tag
}

# 创建虚拟中心。
resource "azurerm_virtual_hub" "virtual_hub" {
  depends_on          = [azurerm_virtual_wan.virtual_wan]
  name                = "vhub-${title(var.customer)}-${upper(var.env)}"
  resource_group_name = "rg-${title(var.customer)}-${upper(var.env)}"
  location            = var.location
  sku                 = lookup(var.vwan_spec, "type", "Standard")
  virtual_wan_id      = azurerm_virtual_wan.virtual_wan.id
  address_prefix      = lookup(var.vwan_spec, "hub_address_prefix", "10.0.1.0/24")
  tags                = var.tag
}

# 创建超级用户虚拟专用网络配置。
resource "azurerm_vpn_server_configuration" "vpn_server_configuration" {
  count                    = lookup(var.vwan_spec, "p2s_vpn", false) ? 1 : 0
  depends_on               = [azurerm_virtual_hub.virtual_hub]
  name                     = "cn-${title(var.customer)}-${upper(var.env)}-superuser"
  resource_group_name      = "rg-${title(var.customer)}-${upper(var.env)}"
  location                 = var.location
  vpn_protocols            = lookup(var.vwan_spec, "vpn_authentication_types", "Certificate") == "Certificate" ? ["IkeV2","OpenVPN"] : ["OpenVPN"]
  vpn_authentication_types = lookup(var.vwan_spec, "vpn_authentication_types", "Certificate")
  tags                     = var.tag
  client_root_certificate {
    name             = "superuser"
    public_cert_data = lookup(var.vwan_spec, "public_cert_data", "")
  }
}

# 创建点对站虚拟专用网络网关。
resource "azurerm_point_to_site_vpn_gateway" "point_to_site_vpn_gateway" {
  count                       = lookup(var.vwan_spec, "p2s_vpn", false) ? 1 : 0
  depends_on                  = [azurerm_vpn_server_configuration.vpn_server_configuration]
  name                        = "cn-${title(var.customer)}-${upper(var.env)}-gateway"
  location                    = var.location
  resource_group_name         = "rg-${title(var.customer)}-${upper(var.env)}"
  virtual_hub_id              = azurerm_virtual_hub.virtual_hub.id
  vpn_server_configuration_id = azurerm_vpn_server_configuration.vpn_server_configuration[0].id
  tags                        = var.tag
  scale_unit                  = 1
  connection_configuration {
    name = "cn-${title(var.customer)}-${upper(var.env)}-gateway-connection"
    vpn_client_address_pool {
      address_prefixes = lookup(var.vwan_spec, "vpn_client_address_pool", "172.31.0.0/16")
    }
  }
}