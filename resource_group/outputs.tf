output "resource_group_id" {
  value = { for i, resource_group in azurerm_resource_group.resource_group: i => resource_group.id }
}