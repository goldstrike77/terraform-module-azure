resource "azurerm_storage_account" "storage_account" {
  for_each                 = var.sa_spec
  name                     = "azsa${lower(var.customer)}${lower(substr(var.environment,0,1))}${each.key}"
  resource_group_name      = "AZ-RG-${title(var.customer)}-${title(var.environment)}"
  location                 = var.location
  account_tier             = each.value.account_tier
  account_replication_type = each.value.account_replication_type
  account_kind             = each.value.account_kind
  tags                     = {
    location    = lower(var.location)
    environment = title(var.environment)
    customer    = title(var.customer)
    owner       = lookup(var.tag, var.tag.owner, "somebody")
    email       = lookup(var.tag, var.tag.email, "somebody@mail.com")
    title       = lookup(var.tag, var.tag.title, "Engineer")
    department  = lookup(var.tag, var.tag.department, "IS")
    costcenter  = lookup(var.tag, var.tag.costcenter, "xx")
    requestor   = lookup(var.tag, var.tag.requestor, "somebody@mail.com")
  }
}