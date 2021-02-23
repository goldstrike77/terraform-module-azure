#### Virtual Networks can be imported using the resource id.
    terraform import module.virtual_network.azurerm_virtual_network.virtual_network /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/AZ-RG-Infra-prd/providers/Microsoft.Network/virtualNetworks/AZ-VN-Infra-prd

#### Usage
```hcl
module "virtual_network" {
  depends_on = [module.virtual_wan]
  source     = "git::https://github.com/goldstrike77/terraform-module-azure.git//virtual_network?ref=v0.2"
  rg_name    = module.resource_group.resource_group_name
  vnet_name  = "vnet-${title(var.customer)}-${lower(var.environment)}-${title(var.project)}"
  vnet_conn  = var.vnet_conn
/*
  vhub_name  = module.virtual_wan.azurerm_virtual_hub_name
*/
  location   = var.location
  vnet_spec  = var.vnet_spec
  tags       = var.tags
}
```