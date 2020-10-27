module "resource_group" {
  source              = "../resource_group"
  resource_group_name = "${var.resource_group_name}"
  location            = "${var.location}"
  tag                 = "${var.tag}"
}

resource "azurerm_virtual_network" "virtual_network" {
  name                = "${var.virtual_network_name}"
  depends_on          = [module.resource_group]
  resource_group_name = "${var.resource_group_name}"
  address_space       = ["${var.virtual_network_cidr}"]
  dns_servers         = "${var.virtual_network_dns}"
  location            = "${var.location}"

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
