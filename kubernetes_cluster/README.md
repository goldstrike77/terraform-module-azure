#### Usage
```hcl
module "kubernetes_cluster" {
  source     = ""
  location   = var.location
  env        = var.env
  customer   = var.customer
  tag        = var.tag
  aks_spec   = var.aks_spec
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

variable "aks_spec" {
  default = {
    c1 = {
      private        = false
      version        = "1.17.13"
      sku_tier       = "Free"
      node_size      = "Standard_B2s"
      auto_scaling   = true
      node_count     = 1
      min_count      = 1
      max_count      = 3
      network_plugin = "kubenet"
      docker_cidr    = "172.17.0.1/16"
      pod_cidr       = "10.244.0.0/16"
      service_cidr   = "10.0.0.0/16"
    }
  }
}

variable "tag" {
  type = map
  default = {
    location    = "chinanorth2"
    environment = "Prd"
    customer    = "Learn"
    owner       = "Somebody"
    email       = "suzhetao@gmail.com"
    title       = "Engineer"
    department  = "IS"
  }
}
```