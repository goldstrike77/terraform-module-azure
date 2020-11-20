# 创建网络安全组。
resource "azurerm_network_security_group" "security_group" {
  name                = "nsg-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}-${title(var.project)}"
  resource_group_name = "rg-${title(var.customer)}-${upper(var.env)}"
  location            = var.location
  tags                = var.tag
}

# 创建网络安全组规则。
resource "azurerm_network_security_rule" "security_rule" {
  depends_on                   = [azurerm_network_security_group.security_group]
  resource_group_name          = "rg-${title(var.customer)}-${upper(var.env)}"
  network_security_group_name  = azurerm_network_security_group.security_group.name
  for_each                     = var.security_group_rules
  name                         = each.key
  direction                    = each.value.direction
  access                       = each.value.access
  priority                     = each.value.priority
  protocol                     = each.value.protocol
  destination_port_range       = length(each.value.destination_port_range[*]) == 1 ? each.value.destination_port_range : null
}