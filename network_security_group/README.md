#### Network Security Groups can be imported using the resource id.
    terraform import module.network_security_group.azurerm_network_security_group.security_group /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/AZ-RG-Infra-prd/providers/Microsoft.Network/networkSecurityGroups/AZ-NSG-Infra-prd-Monitor

#### Usage
```hcl
module "network_security_group" {
  count                = var.security_group_ass ? 1 : 0
  depends_on           = [module.resource_group,module.virtual_network]
  source               = "../../../terraform-module-azure/network_security_group"
  location             = var.location
  environment          = var.environment
  project              = var.project
  customer             = var.customer
  tag                  = var.tag
  security_group_rules = var.security_group_rules
}

```