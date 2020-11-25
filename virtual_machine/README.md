#### Usage
```hcl
module "virtual_machine" {
  depends_on = [module.subnet]
  source     = ""
  location   = var.location
  env        = var.env
  project    = var.project
  customer   = var.customer
  tag        = var.tag
  vm_auth    = var.vm_auth
  vm_spec    = var.vm_spec
  vm_backup  = var.vm_backup
}
```