resource "azurerm_recovery_services_vault" "recovery_services_vault" {
  name                = "AZ-RSV-${title(var.customer)}-${title(var.environment)}"
  location            = var.location
  resource_group_name = "AZ-RG-${title(var.customer)}-${title(var.environment)}"
  sku                 = "Standard"
  soft_delete_enabled = true
  tags                = {
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