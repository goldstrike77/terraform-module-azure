#### Resource Groups can be imported using the resource id.
    terraform import module.resource_group.azurerm_resource_group.resource_group /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-Learn-prd-Support-Network

#### Usage
```hcl
module "resource_group" {
  source   = "git::https://github.com/goldstrike77/terraform-module-azure.git//resource_group?ref=v0.1"
  name     = "rg-${title(var.customer)}-${lower(var.environment)}-${title(var.project)}-Network"
  location = var.location
  tags     = var.tag
}

output "resource_group" {
  value = module.resource_group.resource_group_id
}
```