# 创建子网。
resource "azurerm_subnet" "subnet" {
  name                 = "snet-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}-${title(var.project)}"
  resource_group_name  = "rg-${title(var.customer)}-${upper(var.env)}"
  virtual_network_name = "vnet-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}"
  address_prefixes     = [var.subnet_prefixes]
}

# 关联安全组。
resource "azurerm_subnet_network_security_group_association" "subnet_security_group" {
  count                     = var.security_group_ass ? 1 : 0
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = var.security_group_id
}