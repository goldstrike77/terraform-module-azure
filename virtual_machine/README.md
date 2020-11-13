#### Usage
```hcl
module "virtual_machine" {
  depends_on            = [module.subnet,module.storage_account,module.recovery_services_vault]
  source                = "../../../terraform-module-azure/virtual_machine"
  location              = var.location
  environment           = var.environment
  project               = var.project
  customer              = var.customer
  tag                   = var.tag
  subnet_id             = module.subnet.azurerm_subnet_id
  vm_user               = var.vm_user
  vm_pass               = var.vm_pass
  vm_spec               = var.vm_spec
  vm_backup_frequency   = var.vm_backup_frequency
  vm_backup_time        = var.vm_backup_time
  vm_backup_timezone    = var.vm_backup_timezone
  vm_backup_count       = var.vm_backup_count
}
```