#### Usage
```hcl
module "application_gateway" {
  depends_on = [module.subnet]
  source     = ""
  location   = var.location
  env        = var.env
  customer   = var.customer
  tag        = var.tag
  agw_spec   = var.agw_spec
}
```