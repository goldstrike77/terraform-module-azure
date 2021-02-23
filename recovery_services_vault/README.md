#### Recovery Services Vaults can be imported using the resource id.
    terraform import module.recovery_services_vault.azurerm_recovery_services_vault.recovery_services_vault /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-Learn-prd-RSV

#### Usage
```hcl
module "recovery_services_vault" {
  source   = "git::https://github.com/goldstrike77/terraform-module-azure.git//recovery_services_vault?ref=v0.2"
  rsv_name = "rsv-${title(var.customer)}-${lower(var.environment)}-${title(var.project)}"
  rg_name  = module.resource_group.resource_group_name
  location = var.location
  tags     = var.tags
}
output "recovery_services_vault" {
  value = module.recovery_services_vault.azurerm_recovery_services_vault_id
}
```