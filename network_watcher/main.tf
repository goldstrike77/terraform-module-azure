resource "azurerm_network_watcher" "network_watcher" {
  name                = "AZ-NW-${var.customer}-${var.environment}-${var.project}"
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