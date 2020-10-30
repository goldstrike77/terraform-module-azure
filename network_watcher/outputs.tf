output "network_watcher_id" {
  value = ["azurerm_network_watcher.network_watcher.*.id"]
}