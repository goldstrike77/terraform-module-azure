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
  source_address_prefix        = lookup(each.value, "source_address_prefix", null)
  source_address_prefixes      = lookup(each.value, "source_address_prefixes", null)
  destination_address_prefix   = lookup(each.value, "destination_address_prefix", null)
  destination_address_prefixes = lookup(each.value, "destination_address_prefixes", null)
  source_port_range            = lookup(each.value, "source_port_range", null)
  source_port_ranges           = lookup(each.value, "source_port_ranges", null)
  destination_port_range       = lookup(each.value, "destination_port_range", null)
  destination_port_ranges      = lookup(each.value, "destination_port_ranges", null)
}