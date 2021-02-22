#### Usage
```hcl
module "virtual_wan" {
  depends_on = [module.resource_group]
  source     = "git::https://github.com/goldstrike77/terraform-module-azure.git//virtual_wan?ref=v0.2"
  rg_name    = module.resource_group.resource_group_name
  vwan_name  = "vwan-${title(var.customer)}-${lower(var.environment)}-${title(var.project)}"
  location   = var.location
  tag        = var.tags
  vwan_spec  = var.vwan_spec
}
```