#### Usage
```hcl
module "lb" {
  depends_on        = [module.subnet,module.virtual_machine]
  source            = "../../../terraform-module-azure/lb"
  location          = var.location
  environment       = var.environment
  project           = var.project
  customer          = var.customer
  tag               = var.tag
  subnet_id         = module.subnet.azurerm_subnet_id
  network_interface = module.virtual_machine.azurerm_network_interface
  vm_spec           = var.vm_spec
}
```