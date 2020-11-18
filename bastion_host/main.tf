# 创建堡垒机专用子网。
resource "azurerm_subnet" "subnet" {
  name                      = "AzureBastionSubnet"
  resource_group_name       = "AZ-RG-${title(var.customer)}-${upper(var.environment)}"
  virtual_network_name      = "AZ-VNet-${title(var.customer)}-${upper(var.environment)}"
  address_prefixes          = [var.bastion_subnet_prefixes]
}

# 创建堡垒机公共IP地址。
resource "azurerm_public_ip" "public_ip" {
  name                = "AZ-WAN-${title(var.customer)}-${upper(var.environment)}-Bastion"
  location            = var.location
  resource_group_name = "AZ-RG-${title(var.customer)}-${upper(var.environment)}"
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tag
}

# 创建堡垒机。
resource "azurerm_bastion_host" "bastion_host" {
  name                = "${title(var.customer)}-${upper(substr(var.environment,0,1))}-Bastion"
  location            = var.location
  resource_group_name = "AZ-RG-${title(var.customer)}-${upper(var.environment)}"
  tags                = var.tag  
  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.subnet.id
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }
}