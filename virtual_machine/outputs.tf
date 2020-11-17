output "azurerm_network_interface" {
  value = { for i, nic in azurerm_network_interface.nic: i => nic.id }
}