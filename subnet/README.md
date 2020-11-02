#### Subnets can be imported using the resource id.
`terraform import module.subnet.azurerm_subnet.subnet /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/AZ-RG-Infra-prd/providers/Microsoft.Network/virtualNetworks/AZ-VN-Infra-prd/subnets/AZ-SN-Infra-prd-Monitor`

#### Usage
```hcl
module "subnet" {
  depends_on           = [module.network_security_group]
  source               = "git::https://github.com/goldstrike77/terraform-module-azure//subnet?ref=v0.1"
  depends_on           = [module.network_security_group]
  location             = var.location
  environment          = var.environment
  project              = var.project
  customer             = var.customer
  tag                  = var.tag
  subnet_prefixes      = var.subnet_prefixes
  nsg_id               = module.network_security_group.network_security_group_id
}
```