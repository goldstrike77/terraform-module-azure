module "resource_group" {
  source              = "../resource_group"
  resource_group_name = var.resource_group_name
  location            = var.location
  tag                 = var.tag
}

resource "azurerm_virtual_network" "virtual_network" {
  name                = var.virtual_network_name
  depends_on          = [module.resource_group]
  resource_group_name = var.resource_group_name
  address_space       = [var.virtual_network_cidr]
  dns_servers         = var.virtual_network_dns
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