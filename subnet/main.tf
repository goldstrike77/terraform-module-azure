resource "azurerm_subnet" "subnet" {
  name                      = "AZ-SN-${var.customer}-${var.environment}-${var.project}"
  resource_group_name       = "AZ-RG-${var.customer}-${var.environment}"
  virtual_network_name      = "AZ-VN-${var.customer}-${var.environment}"
  address_prefixes          = [var.subnet_prefixes]
}

resource "azurerm_subnet_network_security_group_association" "subnet_security_group" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = var.nsg_id
}