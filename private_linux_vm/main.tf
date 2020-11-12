locals {
  vm_flat = flatten([
    for s in var.vm_spec : [
      for i in range(s.count) : {
        component = s.component
        type      = s.type
        size      = s.size
        publisher = s.publisher
        offer     = s.offer
        sku       = s.sku
        version   = s.version
        disc_type = s.disc_type
        disc_size = s.disc_size
        index     = i
      }
    ]
  ])
}

resource "azurerm_availability_set" "avset" {
  name                         = "AZ-AVset-${title(var.customer)}-${title(var.environment)}-${title(var.project)}"
  location                     = var.location
  resource_group_name          = "AZ-RG-${title(var.customer)}-${title(var.environment)}"
  platform_fault_domain_count  = 2
  platform_update_domain_count = 5
  managed                      = true
  tags                         = {
    location    = lower(var.location)
    environment = title(var.environment)
    project     = title(var.project)
    customer    = title(var.customer)
    owner       = lookup(var.tag, var.tag.owner, "somebody")
    email       = lookup(var.tag, var.tag.email, "somebody@mail.com")
    title       = lookup(var.tag, var.tag.title, "Engineer")
    department  = lookup(var.tag, var.tag.department, "IS")
    costcenter  = lookup(var.tag, var.tag.costcenter, "xx")
    requestor   = lookup(var.tag, var.tag.requestor, "somebody@mail.com")
  }
}

resource "azurerm_network_interface" "nic" {
  for_each            = { for s in local.vm_flat : format("%s%02d", s.component, s.index+1) => s }
  name                = "AZ-NIC-${title(var.customer)}-${title(var.environment)}-${title(var.project)}-${each.key}"
  location            = var.location
  resource_group_name = "AZ-RG-${title(var.customer)}-${title(var.environment)}"
  tags                = {
    location    = lower(var.location)
    environment = title(var.environment)
    project     = title(var.project)
    customer    = title(var.customer)
    owner       = lookup(var.tag, var.tag.owner, "somebody")
    email       = lookup(var.tag, var.tag.email, "somebody@mail.com")
    title       = lookup(var.tag, var.tag.title, "Engineer")
    department  = lookup(var.tag, var.tag.department, "IS")
    costcenter  = lookup(var.tag, var.tag.costcenter, "xx")
    requestor   = lookup(var.tag, var.tag.requestor, "somebody@mail.com")
  }
  ip_configuration {
    name                          = "AZ-LAN-${title(var.customer)}-${title(var.environment)}-${title(var.project)}-${each.key}"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  depends_on                      = [azurerm_network_interface.nic, azurerm_availability_set.avset]
  for_each                        = { for s in local.vm_flat : format("%s%02d", s.component, s.index+1 ) => s }
  name                            = "AZ-VM-${title(var.customer)}-${upper(substr(var.environment,0,1))}-${title(var.project)}-${each.key}"
  location                        = var.location
  resource_group_name             = "AZ-RG-${title(var.customer)}-${title(var.environment)}"
  availability_set_id             = azurerm_availability_set.avset.id
  network_interface_ids           = [azurerm_network_interface.nic[each.key].id]
  size                            = each.value.size
  computer_name                   = "AZ-VM-${title(var.customer)}-${upper(substr(var.environment,0,1))}-${title(var.project)}-${each.key}"
  admin_username                  = var.vm_user
  admin_password                  = var.vm_pass
  disable_password_authentication = false
  os_disk {
    name                 = "AZ-VM-${title(var.customer)}-${upper(substr(var.environment,0,1))}-${title(var.project)}-${each.key}-OS-Disc0"
    caching              = each.value.disc_type == "Premium_LRS" ? "None" : "ReadWrite"
    storage_account_type = each.value.disc_type
  }
  source_image_reference {
    publisher = each.value.publisher
    offer     = each.value.offer
    sku       = each.value.sku
    version   = each.value.version
  }
  tags          = {
    location    = lower(var.location)
    environment = title(var.environment)
    project     = title(var.project)
    customer    = title(var.customer)
    owner       = lookup(var.tag, var.tag.owner, "somebody")
    email       = lookup(var.tag, var.tag.email, "somebody@mail.com")
    title       = lookup(var.tag, var.tag.title, "Engineer")
    department  = lookup(var.tag, var.tag.department, "IS")
    costcenter  = lookup(var.tag, var.tag.costcenter, "xx")
    requestor   = lookup(var.tag, var.tag.requestor, "somebody@mail.com")
  }
}

resource "azurerm_managed_disk" "data_disc" {
  depends_on           = [azurerm_linux_virtual_machine.vm]
  for_each             = { for s in local.vm_flat : format("%s%02d", s.component, s.index+1 ) => s if s.disc_size > 0 }
  name                 = "AZ-VM-${title(var.customer)}-${upper(substr(var.environment,0,1))}-${title(var.project)}-${each.key}-DT-Disc0"
  location             = var.location
  resource_group_name  = "AZ-RG-${title(var.customer)}-${title(var.environment)}"
  storage_account_type = each.value.disc_type
  create_option        = "Empty"
  disk_size_gb         = each.value.disc_size
}

resource "azurerm_virtual_machine_data_disk_attachment" "data_disk_attachment" {
  depends_on         = [azurerm_managed_disk.data_disc]
  for_each           = { for s in local.vm_flat : format("%s%02d", s.component, s.index+1 ) => s if s.disc_size > 0 }
  managed_disk_id    = azurerm_managed_disk.data_disc[each.key].id
  virtual_machine_id = azurerm_linux_virtual_machine.vm[each.key].id
  lun                = "0"
  caching            = each.value.disc_type == "Premium_LRS" ? "None" : "ReadWrite"
}