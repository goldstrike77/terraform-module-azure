variable "resource_group_name" {}

variable "nsg_name" {}

variable "nsgr_name" {
  type = "list"
}

variable "nsgr_priority" {
  type = "list"
}

variable "nsgr_direction" {
  type = "list"
}

variable "nsgr_access" {
  type = "list"
}

variable "nsgr_prot" {
  type = "list"
}

variable "nsgr_sour_port" {
  type = "list"
}

variable "nsgr_dest_port" {
  type = "list"
}

variable "nsgr_sour_addr" {
  type = "list"
}

variable "nsgr_dest_addr" {
  type = "list"
}

variable "location" {}

variable "subnet_names" {}

variable "subnet_prefixes" {}

variable "virtual_network_name" {}

variable "virtual_network_cidr" {}

variable "virtual_network_dns" {
  type = "list"
}

variable "tag" {
  type = "map"
}
