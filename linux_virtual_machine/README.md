#### Usage
```hcl
module "private_linux_vm" {
  depends_on       = [module.subnet]
  source           = "../../../terraform-module-azure/linux_virtual_machine"
  location         = var.location
  environment      = var.environment
  project          = var.project
  customer         = var.customer
  tag              = var.tag
  subnet_id        = module.subnet.azurerm_subnet_id
  vm_user          = var.vm_user
  vm_pass          = var.vm_pass
  vm_spec          = var.vm_spec
}
```