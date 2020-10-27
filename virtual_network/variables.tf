variable "resource_group_name" {}

variable "location" {}

variable "virtual_network_name" {}

variable "virtual_network_cidr" {}

variable "virtual_network_dns" {type = list}

variable "tag" {type = map}