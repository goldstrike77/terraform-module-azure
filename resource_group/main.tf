resource "azurerm_resource_group" "resource_group" {
  name     = "AZ-RG-${title(var.customer)}-${lower(var.environment)}"
  location = var.location
  tags     = {
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