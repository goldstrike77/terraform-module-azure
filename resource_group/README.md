#### Resource Groups can be imported using the resource id.
    terraform import module.resource_group.azurerm_resource_group.resource_group /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/AZ-RG-Infra-prd

#### Usage
```hcl
module "resource_group" {
  source   = ""
  rg_spec  = var.rg_spec
}
output "resource_group" {
  value = module.resource_group.resource_group_id
}
```