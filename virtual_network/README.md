#### Virtual Networks can be imported using the resource id.
    terraform import module.virtual_network.azurerm_virtual_network.virtual_network /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/AZ-RG-Infra-prd/providers/Microsoft.Network/virtualNetworks/AZ-VN-Infra-prd

#### Usage
```hcl
module "virtual_network" {
  depends_on = [module.resource_group]
  source     = ""
  location   = var.location
  env        = var.env
  customer   = var.customer
  vnet_conn  = var.vnet_conn
  vnet_spec  = var.vnet_spec
}
output "virtual_network" {
  value = module.virtual_network.azurerm_virtual_network_id
}
output "virtual_network_peering" {
  value = module.virtual_network.azurerm_virtual_network_peering_id
}
```