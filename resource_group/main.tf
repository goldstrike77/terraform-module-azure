resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_name
  location = var.location
  tags     = {
    owner       = lookup(var.tag, var.tag.owner, "somebody")
    email       = lookup(var.tag, var.tag.email, "somebody@mail.com")
    title       = lookup(var.tag, var.tag.title, "Engineer")
    department  = lookup(var.tag, var.tag.department, "IS")
    location    = lookup(var.tag, var.tag.location, "chinanorth")
    project     = lookup(var.tag, var.tag.project, "Test")
    environment = lookup(var.tag, var.tag.environment, "SIT")
  }
}