module "virtual_network" {
  source               = "../virtual_network"
  resource_group_name  = var.resource_group_name
  location             = var.location
  virtual_network_name = var.virtual_network_name
  virtual_network_cidr = var.virtual_network_cidr
  virtual_network_dns  = var.virtual_network_dns
  tag                  = var.tag
}

resource "azurerm_network_security_group" "security_group" {
  name                = var.nsg_name
  depends_on          = [module.virtual_network]
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = {
    owner       = lookup(var.tag, var.tag.owner, "somebody")
    email       = lookup(var.tag, var.tag.email, "somebody@mail.com")
    title       = lookup(var.tag, var.tag.title, "Engineer")
    department  = lookup(var.tag, var.tag.department, "IS")
    location    = lookup(var.tag, var.tag.location, "chinanorth")
    project     = lookup(var.tag, var.tag.project, "Test")
    environment = lookup(var.tag, var.tag.environment, "SIT")
  }
}

resource "azurerm_network_security_rule" "security_rule" {
  depends_on                  = [azurerm_network_security_group.security_group]
  resource_group_name         = var.resource_group_name
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