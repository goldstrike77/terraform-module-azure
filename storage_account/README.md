#### Storage Accounts can be imported using the resource id.
`terraform import module.resazurerm_storage_account.azurerm_resazurerm_storage_account.storage_account /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/AZ-RG-Infra-Prd/providers/Microsoft.Storage/storageAccounts/azsainfrapbootdiag`

#### Usage
```hcl
module "storage_account" {
  depends_on  = [module.resource_group]
  source      = "../../../terraform-module-azure/storage_account"
  location    = var.location
  environment = var.environment
  customer    = var.customer
  tag         = var.tag
  sa_spec     = var.sa_spec
}
```