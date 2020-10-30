resource "azurerm_subnet" "subnet" {
  name                      = var.subnet_names
  resource_group_name       = "AZ-RG-${var.customer}-${var.environment}-${var.project}"
  virtual_network_name      = "AZ-VN-${var.customer}-${var.environment}-${var.project}"
  address_prefixes          = [var.subnet_prefixes]
}

resource "azurerm_subnet_network_security_group_association" "subnet_security_group" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = var.network_security_group_id
}