# 创建堡垒机专用子网。
resource "azurerm_subnet" "subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.bastion_vnet_rg
  virtual_network_name = var.bastion_vnet
  address_prefixes     = [var.bastion_subnet_prefixes]
}

# 创建堡垒机公共IP地址。
resource "azurerm_public_ip" "public_bastion" {
  name                = "pip-${var.bastion_name}"
  location            = var.location
  resource_group_name = var.bastion_vnet_rg
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# 创建堡垒机。
resource "azurerm_bastion_host" "bastion_host" {
  name                = var.bastion_name
  location            = var.location
  resource_group_name = var.rg_name
  tags                = var.tags
  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.subnet.id
    public_ip_address_id = azurerm_public_ip.public_bastion.id
  }
}