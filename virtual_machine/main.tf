locals {
  vm_flat = flatten([
    for s in var.vm_spec : [
      for i in range(s.count) : {
        component = s.component
        type      = s.type
        backup    = s.backup
        size      = s.size
        publisher = s.publisher
        offer     = s.offer
        sku       = s.sku
        version   = s.version
        public_ip = s.public_ip
        disc_type = s.disc_type
        disc_size = s.disc_size
        index     = i
      }
    ]
  ])
}

data "azurerm_storage_account" "storage_account" {
  name                = "azsa${lower(var.customer)}${lower(substr(var.environment,0,1))}bootdiag"
  resource_group_name = "AZ-RG-${title(var.customer)}-${title(var.environment)}"
}

resource "azurerm_availability_set" "avset" {
  name                         = "AZ-AVset-${title(var.customer)}-${title(var.environment)}-${title(var.project)}-Linux"
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

resource "azurerm_backup_policy_vm" "backup_policy_vm" {
  name                = "AZ-BPVM-${title(var.customer)}-${upper(var.environment)}-${title(var.project)}"
  resource_group_name = "AZ-RG-${title(var.customer)}-${title(var.environment)}"
  recovery_vault_name = "AZ-RSV-${title(var.customer)}-${title(var.environment)}"
  timezone            = var.vm_backup_timezone
  backup {
    frequency = title(var.vm_backup_frequency)
    time      = var.vm_backup_time
  }
  retention_daily {
    count = var.vm_backup_count
  }
  tags = {
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

resource "azurerm_public_ip" "public_ip" {
  for_each            = { for s in local.vm_flat : format("%s%02d", s.component, s.index+1) => s if s.public_ip }
  name                = "AZ-WAN-${title(var.customer)}-${title(var.environment)}-${title(var.project)}-${each.key}"
  location            = var.location
  resource_group_name = "AZ-RG-${title(var.customer)}-${title(var.environment)}"
  sku                 = "Standard"
  allocation_method   = "Static"
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
  depends_on          = [azurerm_public_ip.public_ip]
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
    public_ip_address_id          = each.value.public_ip ? azurerm_public_ip.public_ip[each.key].id : null
  }
}

# Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "vm" {
  depends_on                      = [azurerm_network_interface.nic, azurerm_availability_set.avset,azurerm_backup_policy_vm.backup_policy_vm]
  for_each                        = { for s in local.vm_flat : format("%s%02d", s.component, s.index+1 ) => s if s.type == "linux" }
  name                            = "${title(var.customer)}-${upper(substr(var.environment,0,1))}-${title(var.project)}-${each.key}"
  location                        = var.location
  resource_group_name             = "AZ-RG-${title(var.customer)}-${title(var.environment)}"
  availability_set_id             = azurerm_availability_set.avset.id
  network_interface_ids           = [azurerm_network_interface.nic[each.key].id]
  size                            = each.value.size
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
  boot_diagnostics {
    storage_account_uri = data.azurerm_storage_account.storage_account.primary_blob_endpoint
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

resource "azurerm_managed_disk" "linux_data_disc" {
  depends_on           = [azurerm_linux_virtual_machine.vm]
  for_each             = { for s in local.vm_flat : format("%s%02d", s.component, s.index+1 ) => s if s.disc_size > 0 && s.type == "linux" }
  name                 = "AZ-VM-${title(var.customer)}-${upper(substr(var.environment,0,1))}-${title(var.project)}-${each.key}-DT-Disc0"
  location             = var.location
  resource_group_name  = "AZ-RG-${title(var.customer)}-${title(var.environment)}"
  storage_account_type = each.value.disc_type
  create_option        = "Empty"
  disk_size_gb         = each.value.disc_size
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
}

resource "azurerm_virtual_machine_data_disk_attachment" "linux_data_disk_attachment" {
  depends_on         = [azurerm_managed_disk.linux_data_disc]
  for_each           = { for s in local.vm_flat : format("%s%02d", s.component, s.index+1 ) => s if s.disc_size > 0 && s.type == "linux" }
  managed_disk_id    = azurerm_managed_disk.linux_data_disc[each.key].id
  virtual_machine_id = azurerm_linux_virtual_machine.vm[each.key].id
  lun                = "0"
  caching            = each.value.disc_type == "Premium_LRS" ? "None" : "ReadWrite"
}

resource "azurerm_backup_protected_vm" "backup_protected_linux_vm" {
  depends_on          = [azurerm_linux_virtual_machine.vm]
  for_each            = { for s in local.vm_flat : format("%s%02d", s.component, s.index+1 ) => s if s.backup && s.type == "linux" }
  resource_group_name = "AZ-RG-${title(var.customer)}-${title(var.environment)}"
  recovery_vault_name = "AZ-RSV-${title(var.customer)}-${title(var.environment)}"
  source_vm_id        = azurerm_linux_virtual_machine.vm[each.key].id
  backup_policy_id    = azurerm_backup_policy_vm.backup_policy_vm.id
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
}

# Windows Virtual Machine
resource "azurerm_windows_virtual_machine" "vm" {
  depends_on                      = [azurerm_network_interface.nic, azurerm_availability_set.avset,azurerm_backup_policy_vm.backup_policy_vm]
  for_each                        = { for s in local.vm_flat : format("%s%02d", s.component, s.index+1 ) => s if s.type == "windows" }
  name                            = "${title(var.customer)}-${upper(substr(var.environment,0,1))}-${title(var.project)}-${each.key}"
  location                        = var.location
  resource_group_name             = "AZ-RG-${title(var.customer)}-${title(var.environment)}"
  availability_set_id             = azurerm_availability_set.avset.id
  network_interface_ids           = [azurerm_network_interface.nic[each.key].id]
  size                            = each.value.size
  admin_username                  = var.vm_user
  admin_password                  = var.vm_pass
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
  boot_diagnostics {
    storage_account_uri = data.azurerm_storage_account.storage_account.primary_blob_endpoint
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

resource "azurerm_managed_disk" "windows_data_disc" {
  depends_on           = [azurerm_windows_virtual_machine.vm]
  for_each             = { for s in local.vm_flat : format("%s%02d", s.component, s.index+1 ) => s if s.disc_size > 0 && s.type == "windows" }
  name                 = "AZ-VM-${title(var.customer)}-${upper(substr(var.environment,0,1))}-${title(var.project)}-${each.key}-DT-Disc0"
  location             = var.location
  resource_group_name  = "AZ-RG-${title(var.customer)}-${title(var.environment)}"
  storage_account_type = each.value.disc_type
  create_option        = "Empty"
  disk_size_gb         = each.value.disc_size
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
}

resource "azurerm_virtual_machine_data_disk_attachment" "windows_data_disk_attachment" {
  depends_on         = [azurerm_managed_disk.windows_data_disc]
  for_each           = { for s in local.vm_flat : format("%s%02d", s.component, s.index+1 ) => s if s.disc_size > 0 && s.type == "windows" }
  managed_disk_id    = azurerm_managed_disk.windows_data_disc[each.key].id
  virtual_machine_id = azurerm_windows_virtual_machine.vm[each.key].id
  lun                = "0"
  caching            = each.value.disc_type == "Premium_LRS" ? "None" : "ReadWrite"
}

resource "azurerm_backup_protected_vm" "backup_protected_windows_vm" {
  depends_on          = [azurerm_windows_virtual_machine.vm]
  for_each            = { for s in local.vm_flat : format("%s%02d", s.component, s.index+1 ) => s if s.backup && s.type == "windows" }
  resource_group_name = "AZ-RG-${title(var.customer)}-${title(var.environment)}"
  recovery_vault_name = "AZ-RSV-${title(var.customer)}-${title(var.environment)}"
  source_vm_id        = azurerm_windows_virtual_machine.vm[each.key].id
  backup_policy_id    = azurerm_backup_policy_vm.backup_policy_vm.id
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
}

resource "azurerm_virtual_machine_extension" "vm" {
  depends_on           = [azurerm_windows_virtual_machine.vm]
  for_each             = { for s in local.vm_flat : format("%s%02d", s.component, s.index+1 ) => s if s.type == "windows" }
  name                 = "WinRM"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm[each.key].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  tags                 = {
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
  settings = <<SETTINGS
  {
    "fileUris": [ "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1" ],
    "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File ConfigureRemotingForAnsible.ps1"
  }
SETTINGS
}