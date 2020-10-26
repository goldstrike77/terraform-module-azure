resource "azurerm_resource_group" "resource_group" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
  
  tags = 
    {
      owner       = "${lookup(var.tag, "owner")}"
      email       = "${lookup(var.tag, "email")}"
      title       = "${lookup(var.tag, "title")}"
      department  = "${lookup(var.tag, "department")}"
      location    = "${lookup(var.tag, "location")}"
      project     = "${lookup(var.tag, "project")}"
      environment = "${lookup(var.tag, "environment")}"
    }
}