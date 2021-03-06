output "azurerm_virtual_network_id" {
  value = { for i, vnet in azurerm_virtual_network.virtual_network: i => vnet.id }
}

output "azurerm_virtual_network_peering_id" {
  value = { for i, peering in azurerm_virtual_network_peering.virtual_network_peering: i => regex(".*/(.*)", peering.id) }
}