#### Usage
```hcl
module "virtual_wan" {
  depends_on = [module.resource_group]
  source     = ""
  location   = var.location
  env        = var.env
  customer   = var.customer
  tag        = var.tag
  vwan_spec  = var.vwan_spec
}
```