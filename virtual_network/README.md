#### Virtual Networks can be imported using the resource id.
`terraform import module.virtual_network.azurerm_virtual_network.virtual_network /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/AZ-RG-Infra-prd/providers/Microsoft.Network/virtualNetworks/AZ-VN-Infra-prd`

#### Usage
```hcl
module "virtual_network" {
  depends_on           = [module.resource_group]
  source               = "../../../terraform-module-azure/virtual_network"
  location             = var.location
  environment          = var.environment
  customer             = var.customer
  tag                  = var.tag
  virtual_network_cidr = var.virtual_network_cidr
  virtual_network_dns  = var.virtual_network_dns
}
```