# 创建网络安全组。
resource "azurerm_network_security_group" "security_group" {
  name                = "AZ-NSG-${title(var.customer)}-${upper(var.environment)}-${title(var.project)}"
  resource_group_name = "AZ-RG-${title(var.customer)}-${upper(var.environment)}"
  location            = var.location
  tags                = var.tag
}

# 创建网络安全组规则。
resource "azurerm_network_security_rule" "security_rule" {
  depends_on                  = [azurerm_network_security_group.security_group]
  resource_group_name         = "AZ-RG-${title(var.customer)}-${upper(var.environment)}"
  network_security_group_name = azurerm_network_security_group.security_group.name
  for_each                    = var.security_group_rules
  name                        = each.key
  direction                   = each.value.direction
  access                      = each.value.access
  priority                    = each.value.priority
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
}