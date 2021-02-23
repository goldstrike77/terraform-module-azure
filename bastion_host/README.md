#### Bastion Hosts can be imported using the resource id.
    terraform import module.bastion_host.azurerm_subnet.subnet /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/AZ-RG-Inf-Prd/providers/Microsoft.Network/virtualNetworks/AZ-VNet-Inf-Prd/subnets/AzureBastionSubnet
    terraform import module.bastion_host.azurerm_public_ip.public_ip /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/AZ-RG-Inf-Prd/providers/Microsoft.Network/publicIPAddresses/AZ-WAN-Inf-Prd-Bastion
    terraform import module.bastion_host.azurerm_bastion_host.bastion_host /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/AZ-RG-Inf-Prd/providers/Microsoft.Network/bastionHosts/Inf-P-Bastion

#### Usage
```hcl
module "bastion_host" {
  source                  = "git::https://github.com/goldstrike77/terraform-module-azure.git//bastion_host?ref=v0.2"
  rg_name                 = module.resource_group.resource_group_name
  location                = var.location
  bastion_name            = "bst-${title(var.customer)}-${lower(var.environment)}-${title(var.project)}"
  bastion_vnet            = "vnet-${title(var.customer)}-${lower(var.environment)}-Network"
  bastion_vnet_rg         = "rg-${title(var.customer)}-${lower(var.environment)}-Network"
  bastion_subnet_prefixes = var.bastion_subnet_prefixes
  tags                    = var.tags
}
```