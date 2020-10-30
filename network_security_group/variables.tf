variable "location" {}
variable "environment" {}
variable "project" {}
variable "customer" {}
variable "tag" { type = map }
variable "nsgr_name" { type = list }
variable "nsgr_priority" { type = list }
variable "nsgr_direction" { type = list }
variable "nsgr_access" { type = list }
variable "nsgr_prot" { type = list }
variable "nsgr_sour_port" { type = list }
variable "nsgr_dest_port" { type = list }
variable "nsgr_sour_addr" { type = list }
variable "nsgr_dest_addr" { type = list }