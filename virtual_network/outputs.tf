output "azurerm_virtual_network_id" {
  value = azurerm_virtual_network.virtual_network.*.id
}

output "azurerm_virtual_network_peering_id" {
  value = azurerm_virtual_network_peering.virtual_network_peering.*.id
}