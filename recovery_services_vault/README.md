#### Recovery Services Vaults can be imported using the resource id.
    terraform import module.recovery_services_vault.azurerm_recovery_services_vault.recovery_services_vault /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/AZ-RG-Infra-prd

#### Usage
```hcl
module "recovery_services_vault" {
  source   = ""
  location = var.location
  env      = var.env
  customer = var.customer
  tag      = var.tag
}
output "recovery_services_vault" {
  value = module.recovery_services_vault.azurerm_recovery_services_vault_id
}
```