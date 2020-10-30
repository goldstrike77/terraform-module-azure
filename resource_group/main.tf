resource "azurerm_resource_group" "resource_group" {
  name     = "AZ-RG-${var.customer}-${var.environment}-${var.project}"
  location = var.location
  tags     = {
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