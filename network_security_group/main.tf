resource "azurerm_network_security_group" "security_group" {
  name                = "AZ-NSG-${var.customer}-${var.environment}-${var.project}"
  resource_group_name = "AZ-RG-${var.customer}-${var.environment}"
  location            = var.location
  tags                = {
    location    = var.location
    environment = var.environment
    project     = var.project
    customer    = var.customer
    owner       = lookup(var.tag, var.tag.owner, "somebody")
    email       = lookup(var.tag, var.tag.email, "somebody@mail.com")
    title       = lookup(var.tag, var.tag.title, "Engineer")
    department  = lookup(var.tag, var.tag.department, "IS")
    costcenter  = lookup(var.tag, var.tag.costcenter, "xx")
    requestor   = lookup(var.tag, var.tag.requestor, "somebody@mail.com")
  }
}

resource "azurerm_network_security_rule" "security_rule" {
  depends_on                  = [azurerm_network_security_group.security_group]
  resource_group_name         = "AZ-RG-${var.customer}-${var.environment}"
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