output "azurerm_storage_account_id" {
  value = { for i, storage_account in azurerm_storage_account.storage_account: i => storage_account.id }
}