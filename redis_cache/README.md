#### Usage
```hcl
module "redis_cache" {
  source     = ""
  location   = var.location
  env        = var.env
  project    = var.project
  customer   = var.customer
  tag        = var.tag
  redis_spec = var.redis_spec
}
```

#### Variables
```hcl
variable "geography" {}

variable "location" {
  default = "chinanorth2"
}

variable "env" {
  default = "prd"
}

variable "customer" {
  default = "Learn"
}

variable "project" {
  default = "P1"
}

variable "redis_spec" {
  default = {
    c1 = {
      capacity       = 1
      sku            = "Standard"
      enable_non_ssl = false
      shard_count    = 3
      authentication = true
      start_ip       = "0.0.0.0"
      end_ip         = "0.0.0.0"
    }
  }
}

variable "tag" {
  type = map
  default = {
    location    = "chinanorth2"
    environment = "Prd"
    customer    = "Learn"
    project     = "P1"
    owner       = "Somebody"
    email       = "suzhetao@gmail.com"
    title       = "Engineer"
    department  = "IS"
  }
}
```