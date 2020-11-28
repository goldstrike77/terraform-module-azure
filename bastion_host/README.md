#### Bastion Hosts can be imported using the resource id.
    terraform import module.bastion_host.azurerm_subnet.subnet /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/AZ-RG-Inf-Prd/providers/Microsoft.Network/virtualNetworks/AZ-VNet-Inf-Prd/subnets/AzureBastionSubnet
    terraform import module.bastion_host.azurerm_public_ip.public_ip /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/AZ-RG-Inf-Prd/providers/Microsoft.Network/publicIPAddresses/AZ-WAN-Inf-Prd-Bastion
    terraform import module.bastion_host.azurerm_bastion_host.bastion_host /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/AZ-RG-Inf-Prd/providers/Microsoft.Network/bastionHosts/Inf-P-Bastion

#### Usage
```hcl
module "bastion_host" {
  source                  = ""
  location                = var.location
  env                     = var.env
  customer                = var.customer
  tag                     = var.tag
  bastion_subnet_prefixes = var.bastion_subnet_prefixes
}
```

#### Variables
```hcl
variable "geography" {}

variable "location" {
  default = "chinanorth2"
}

variable "env" {
  default = "prd"
}

variable "customer" {
  default = "Learn"
}

variable "bastion_subnet_prefixes" {
  default = "10.10.0.0/24"
}

variable "tag" {
  type = map
  default = {
    location    = "chinanorth2"
    environment = "Prd"
    customer    = "Learn"
    project     = "Bastion"
    owner       = "Somebody"
    email       = "suzhetao@gmail.com"
    title       = "Engineer"
    department  = "IS"
  }
}
```