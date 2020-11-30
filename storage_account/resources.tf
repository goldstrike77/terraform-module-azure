# 创建存储账户。
resource "azurerm_storage_account" "storage_account" {
  for_each                 = var.sa_spec
  name                     = "sa${lower(var.customer)}${lower(substr(var.env,0,1))}${each.key}"
  resource_group_name      = "rg-${title(var.customer)}-${upper(var.env)}"
  location                 = var.location
  account_tier             = each.value.account_tier
  account_replication_type = each.value.account_replication_type
  account_kind             = each.value.account_kind
  allow_blob_public_access = each.value.allow_blob_public_access ? true : false
  tags                     = var.tag
}