# 创建Kubernetes集群。
resource "azurerm_kubernetes_cluster" "kubernetes_cluster" {
  for_each                = var.aks_spec
  name                    = "aks-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}-${title(each.key)}"
  location                = var.location
  resource_group_name     = "rg-${title(var.customer)}-${upper(var.env)}"
  node_resource_group     = "rg-${title(var.customer)}-${upper(var.env)}-${title(each.key)}-aks"
  dns_prefix              = "aks-${lower(var.customer)}-${lower(var.env)}-${lower(var.location)}"
  kubernetes_version      = lookup(each.value, "version", "1.17.13")
  private_cluster_enabled = lookup(each.value, "private", true)
  sku_tier                = lookup(each.value, "sku_tier", "Free")
  tags                    = var.tag
  network_profile {
    docker_bridge_cidr = lookup(each.value, "docker_cidr", "172.17.0.1/16")
    pod_cidr           = lookup(each.value, "pod_cidr", "10.244.0.0/16")
    service_cidr       = lookup(each.value, "service_cidr", "10.0.0.0/16")
    dns_service_ip     = cidrhost(lookup(each.value, "service_cidr", "10.0.0.0/16"), 10)
    network_plugin     = lookup(each.value, "network_plugin", "kubenet")
  }
  default_node_pool {
    name                = "${lower(var.customer)}${lower(substr(var.env,0,1))}${lower(each.key)}"
    vm_size             = lookup(each.value, "node_size", "Standard_B2s")
    enable_auto_scaling = lookup(each.value, "auto_scaling", false)
    node_count          = lookup(each.value, "node_count", 1)
    max_count           = lookup(each.value, "max_count", 3)
    min_count           = lookup(each.value, "min_count", 1)
    tags                = var.tag
  }
  identity {
    type = "SystemAssigned"
  }
}