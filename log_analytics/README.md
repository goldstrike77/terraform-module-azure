#### Usage
```hcl
module "log_analytics" {
  source   = "/home/suzhetao/terraform/terraform-module-azure/log_analytics"
  location = var.location
  customer = var.customer
  tag      = var.tag
  log_spec = var.log_spec
}

output "log_analytics_workspace_primary_shared_key" {
  value = module.log_analytics.log_analytics_workspace_primary_shared_key
}
```

#### Variables
```hcl
variable "geography" {}

variable "location" {
  default = "chinaeast2"
}

variable "customer" {
  default = "Learn"
}

variable "log_spec" {
  default = {
    retention_in_days = 180
    internet_ingestion_enabled = false
    internet_query_enabled = false
  }
}

variable "tag" {
  type = map
  default = {
    location    = "chinaeast2"
    customer    = "Learn"
    environment = "Prd"
    project     = "LogAnalytics"
    owner       = "Somebody"
    email       = "suzhetao@gmail.com"
    title       = "Engineer"
    department  = "IS"
  }
}
```