# 创建堡垒机专用子网。
resource "azurerm_subnet" "subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = "rg-${title(var.customer)}-${upper(var.env)}"
  virtual_network_name = "vnet-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}"
  address_prefixes     = [var.bastion_subnet_prefixes]
}

# 创建堡垒机公共IP地址。
resource "azurerm_public_ip" "public_bastion" {
  name                = "pip-bastion-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}"
  location            = var.location
  resource_group_name = "rg-${title(var.customer)}-${upper(var.env)}"
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "pip-bastion-${lower(var.customer)}-${lower(var.env)}"
  tags                = var.tag
}

# 创建堡垒机。
resource "azurerm_bastion_host" "bastion_host" {
  name                = "bst-${title(var.customer)}-${upper(substr(var.env,0,1))}-${lower(var.location)}"
  location            = var.location
  resource_group_name = "rg-${title(var.customer)}-${upper(var.env)}"
  tags                = var.tag  
  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.subnet.id
    public_ip_address_id = azurerm_public_ip.public_bastion.id
  }
}