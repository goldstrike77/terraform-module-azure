variable "project_name" {}

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

variable "win_vm_name" {
  type = "list"
}

variable "win_vm_size" {
  type = "list"
}

variable "win_disc_type" {
  type = "list"
}

variable "win_disc_size" {
  type = "list"
}

variable "win_vm_publisher" {
  type = "string"
}

variable "win_vm_offer" {
  type = "string"
}

variable "win_vm_sku" {
  type = "string"
}

variable "win_vm_version" {
  type = "string"
}

variable "vm_admin_username" {}

variable "vm_admin_password" {}

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
