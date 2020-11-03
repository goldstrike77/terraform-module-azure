resource "azurerm_subnet" "subnet" {
  name                      = "AZ-SNet-${title(var.customer)}-${lower(var.environment)}-${title(var.project)}"
  resource_group_name       = "AZ-RG-${title(var.customer)}-${lower(var.environment)}"
  virtual_network_name      = "AZ-VNet-${title(var.customer)}-${lower(var.environment)}"
  address_prefixes          = [var.subnet_prefixes]
}

resource "azurerm_subnet_network_security_group_association" "subnet_security_group" {
  count                     = var.security_group_ass ? 1 : 0
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = var.security_group_id
}