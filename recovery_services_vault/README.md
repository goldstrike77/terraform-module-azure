#### Recovery Services Vaults can be imported using the resource id.
`terraform import module.recovery_services_vault.azurerm_recovery_services_vault.recovery_services_vault /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/AZ-RG-Infra-prd`

#### Usage
```hcl
module "recovery_services_vault" {
  depends_on  = [module.resource_group]
  source      = "../../../terraform-module-azure/recovery_services_vault"
  location    = var.location
  environment = var.environment
  customer    = var.customer
  tag         = var.tag
}
```