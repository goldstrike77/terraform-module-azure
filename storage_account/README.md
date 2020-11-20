#### Storage Accounts can be imported using the resource id.
    terraform import module.resazurerm_storage_account.azurerm_resazurerm_storage_account.storage_account /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/AZ-RG-Infra-Prd/providers/Microsoft.Storage/storageAccounts/azsainfrapbootdiag

#### Usage
```hcl
module "recovery_services_vault" {
  location = var.location
  env      = var.env
  customer = var.customer
  tag      = var.tag
  sa_spec  = var.sa_spec
}
output "recovery_services_vault" {
  value = module.recovery_services_vault.azurerm_recovery_services_vault_id
}
```