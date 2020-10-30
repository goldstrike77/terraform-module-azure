```yaml
module "resource_group" {
  source      = "git::https://github.com/goldstrike77/terraform-module-azure//resource_group?ref=v0.1"
  location    = var.location
  environment = var.environment
  project     = var.project
  customer    = var.customer
  tag         = var.tag
}
```