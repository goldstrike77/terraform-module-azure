output "azurerm_network_interface" {
  value = { for i, nic in azurerm_network_interface.nic: i => nic.id }
}

output "azurerm_linux_virtual_machine" {
  value = { for i, vm in azurerm_linux_virtual_machine.vm: i => regex(".*/(.*)", vm.id) }
}

output "azurerm_windows_virtual_machine" {
 value = { for i, vm in azurerm_linux_virtual_machine.vm: i => regex(".*/(.*)", vm.id) }
}