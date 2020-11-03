resource "azurerm_virtual_network" "virtual_network" {
  name                = "AZ-VNet-${title(var.customer)}-${lower(var.environment)}"
  resource_group_name = "AZ-RG-${title(var.customer)}-${lower(var.environment)}"
  address_space       = [var.virtual_network_cidr]
  dns_servers         = var.virtual_network_dns
  location            = var.location
  tags                = {
    location    = lower(var.location)
    environment = lower(var.environment)
    customer    = title(var.customer)
    owner       = lookup(var.tag, var.tag.owner, "somebody")
    email       = lookup(var.tag, var.tag.email, "somebody@mail.com")
    title       = lookup(var.tag, var.tag.title, "Engineer")
    department  = lookup(var.tag, var.tag.department, "IS")
    costcenter  = lookup(var.tag, var.tag.costcenter, "xx")
    requestor   = lookup(var.tag, var.tag.requestor, "somebody@mail.com")
  }
}