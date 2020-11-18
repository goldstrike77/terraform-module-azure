output "azurerm_virtual_network_id" {
  value = { for i, virtual_network in azurerm_virtual_network.virtual_network: i => virtual_network.id }
}