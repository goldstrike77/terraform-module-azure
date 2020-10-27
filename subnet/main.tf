module "network_security_group" {
  source               = "../network_security_group"
  resource_group_name  = "${var.resource_group_name}"
  location             = "${var.location}"
  virtual_network_name = "${var.virtual_network_name}"
  virtual_network_cidr = "${var.virtual_network_cidr}"
  virtual_network_dns  = "${var.virtual_network_dns}"
  nsg_name             = "${var.nsg_name}"
  nsgr_name            = "${var.nsgr_name}"
  nsgr_priority        = "${var.nsgr_priority}"
  nsgr_direction       = "${var.nsgr_direction}"
  nsgr_access          = "${var.nsgr_access}"
  nsgr_prot            = "${var.nsgr_prot}"
  nsgr_sour_port       = "${var.nsgr_sour_port}"
  nsgr_dest_port       = "${var.nsgr_dest_port}"
  nsgr_sour_addr       = "${var.nsgr_sour_addr}"
  nsgr_dest_addr       = "${var.nsgr_dest_addr}"
  tag                  = "${var.tag}"
}

resource "azurerm_subnet" "subnet" {
  name                      = "${var.subnet_names}"
  depends_on                = [module.network_security_group]
  resource_group_name       = "${var.resource_group_name}"
  virtual_network_name      = "${var.virtual_network_name}"
  network_security_group_id = "${module.network_security_group.network_security_group_id}"
  address_prefix            = "${var.subnet_prefixes}"
}
