#### Usage
```hcl
module "subnet" {
  depends_on         = [module.network_security_group]
  source             = ""
  location           = var.location
  env                = var.env
  project            = var.project
  customer           = var.customer
  tag                = var.tag
  subnet_prefixes    = var.subnet_prefixes
  security_group_ass = var.security_group_ass
  security_group_id  = ( var.security_group_ass ? module.network_security_group[0].net_security_group_id : 0 )
}
```