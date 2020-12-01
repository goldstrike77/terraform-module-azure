output "aks_client_certificate" {
  value = { for i, kube_config in azurerm_kubernetes_cluster.kubernetes_cluster: i => kube_config }
}

output "aks_kube_config" {
  value = { for i, kube_config_raw in azurerm_kubernetes_cluster.kubernetes_cluster: i => kube_config_raw }
}