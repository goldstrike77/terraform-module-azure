#### Resource Groups can be imported using the resource id.
`terraform import module.resource_group.azurerm_resource_group.resource_group /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/AZ-RG-Infra-prd`

#### Usage
```hcl
module "resource_group" {
  source      = "git::https://github.com/goldstrike77/terraform-module-azure//resource_group?ref=v0.1"
  location    = var.location
  environment = var.environment
  customer    = var.customer
  tag         = var.tag
}
```