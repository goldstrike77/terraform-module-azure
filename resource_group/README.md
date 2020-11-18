#### Resource Groups can be imported using the resource id.
    terraform import module.resource_group.azurerm_resource_group.resource_group /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/AZ-RG-Infra-prd

#### Usage
```hcl
module "resource_group" {
  source      = "../terraform-module-azure/resource_group"
  customer    = var.customer
  rg_spec     = var.rg_spec
}
```