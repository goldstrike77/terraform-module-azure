resource "azurerm_virtual_network" "virtual_network" {
  name                = "AZ-VN-${var.customer}-${var.environment}"
  resource_group_name = "AZ-RG-${var.customer}-${var.environment}"
  address_space       = [var.virtual_network_cidr]
  dns_servers         = var.virtual_network_dns
  location            = var.location
  tags                = {
    location    = var.location
    environment = var.environment
    customer    = var.customer
    owner       = lookup(var.tag, var.tag.owner, "somebody")
    email       = lookup(var.tag, var.tag.email, "somebody@mail.com")
    title       = lookup(var.tag, var.tag.title, "Engineer")
    department  = lookup(var.tag, var.tag.department, "IS")
    costcenter  = lookup(var.tag, var.tag.costcenter, "xx")
    requestor   = lookup(var.tag, var.tag.requestor, "somebody@mail.com")
  }
}