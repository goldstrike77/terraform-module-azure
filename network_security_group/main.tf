resource "azurerm_network_security_group" "security_group" {
  name                = "AZ-NSG-${var.customer}-${var.environment}-${var.project}"
  resource_group_name = "AZ-RG-${var.customer}-${var.environment}-${var.project}"
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
  resource_group_name         = "AZ-RG-${var.customer}-${var.environment}-${var.project}"
  network_security_group_name = azurerm_network_security_group.security_group.name
  count                       = length(var.nsgr_name)
  name                        = var.nsgr_name[count.index]
  priority                    = var.nsgr_priority[count.index]
  direction                   = var.nsgr_direction[count.index]
  access                      = var.nsgr_access[count.index]
  protocol                    = var.nsgr_prot[count.index]
  source_port_range           = var.nsgr_sour_port[count.index]
  destination_port_range      = var.nsgr_dest_port[count.index]
  source_address_prefix       = var.nsgr_sour_addr[count.index]
  destination_address_prefix  = var.nsgr_dest_addr[count.index]
}