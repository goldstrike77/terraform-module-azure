# 获取虚拟机子网编号。
data "azurerm_subnet" "subnet_vm" {
  name                 = "snet-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}-${title(var.project)}"
  resource_group_name  = "rg-${title(var.customer)}-${upper(var.env)}"
  virtual_network_name = "vnet-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}"
}

# 创建可用性集。
resource "azurerm_availability_set" "avset" {
  name                         = "avail-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}-${title(var.project)}"
  location                     = var.location
  resource_group_name          = "rg-${title(var.customer)}-${upper(var.env)}"
  platform_fault_domain_count  = 2
  platform_update_domain_count = 5
  managed                      = true
  tags                         = var.tag
}

# 创建备份策略。
resource "azurerm_backup_policy_vm" "backup_policy_vm" {
  depends_on          = [azurerm_linux_virtual_machine.vm,azurerm_windows_virtual_machine.vm]
  name                = "policy-${title(var.customer)}-${upper(var.env)}-${title(var.project)}-vm"
  resource_group_name = "rg-${title(var.customer)}-${upper(var.env)}"
  recovery_vault_name = "rsv-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}"
  timezone            = lookup(var.vm_backup, "timezone", "China Standard Time")
  backup {
    frequency = title(lookup(var.vm_backup, "frequency", "daily"))
    time      = lookup(var.vm_backup, "time", "23:00")
  }
  retention_daily {
    count = lookup(var.vm_backup, "count", 7)
  }
}

# 创建公共IP地址。
resource "azurerm_public_ip" "public_ip" {
  for_each            = { for s in local.vm_flat : format("%s%02d", s.component, s.index+1) => s if s.public }
  name                = "pip-vm-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}-${title(var.project)}-${each.key}"
  location            = var.location
  resource_group_name = "rg-${title(var.customer)}-${upper(var.env)}"
  sku                 = "Standard"
  allocation_method   = "Static"
  domain_name_label   = "pip-vm-${lower(var.customer)}-${lower(var.env)}-${lower(var.project)}-${each.key}"
  tags                = var.tag
}

# 创建网络接口。
resource "azurerm_network_interface" "nic" {
  depends_on                    = [azurerm_public_ip.public_ip]
  for_each                      = { for s in local.vm_flat : format("%s%02d", s.component, s.index+1) => s }
  name                          = "nic-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}-${title(var.project)}-${each.key}"
  location                      = var.location
  resource_group_name           = "rg-${title(var.customer)}-${upper(var.env)}"
  enable_ip_forwarding          = each.value.ip_forwarding
  enable_accelerated_networking = each.value.accelerated_networking
  tags                          = var.tag
  ip_configuration {
    name                          = "ip-vm-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}-${title(var.project)}-${each.key}"
    subnet_id                     = data.azurerm_subnet.subnet_vm.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = each.value.public ? azurerm_public_ip.public_ip[each.key].id : null
  }
}

# 创建Linux虚拟机。
resource "azurerm_linux_virtual_machine" "vm" {
  depends_on                      = [azurerm_network_interface.nic, azurerm_availability_set.avset]
  for_each                        = { for s in local.vm_flat : format("%s%02d", s.component, s.index+1 ) => s if s.type == "linux" }
  name                            = "vm-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}-${title(var.project)}-${each.key}"
  location                        = var.location
  resource_group_name             = "rg-${title(var.customer)}-${upper(var.env)}"
  availability_set_id             = azurerm_availability_set.avset.id
  network_interface_ids           = [azurerm_network_interface.nic[each.key].id]
  size                            = each.value.size
  computer_name                   = "${title(var.customer)}-${upper(substr(var.env,0,1))}-${title(var.project)}-${each.key}"
  admin_username                  = lookup(var.vm_auth, "user", "oper")
  admin_password                  = lookup(var.vm_auth, "pass", "aGhQpYPQd9vzPH8k")
  disable_password_authentication = false
  tags                            = var.tag
  os_disk {
    name                 = "osdisk-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}-${title(var.project)}-${each.key}"
    caching              = each.value.disc_type == "Premium_LRS" ? "None" : "ReadWrite"
    storage_account_type = each.value.disc_type
  }
  source_image_reference {
    publisher = each.value.publisher
    offer     = each.value.offer
    sku       = each.value.sku
    version   = each.value.version
  }
  boot_diagnostics {}
}

# 创建Linux虚拟机数据磁盘。
resource "azurerm_managed_disk" "linux_data_disk" {
  depends_on           = [azurerm_linux_virtual_machine.vm]
  for_each             = { for s in local.vm_flat : format("%s%02d", s.component, s.index+1 ) => s if s.disc_size > 0 && s.type == "linux" }
  name                 = "disk-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}-${title(var.project)}-${each.key}"
  location             = var.location
  resource_group_name  = "rg-${title(var.customer)}-${upper(var.env)}"
  storage_account_type = each.value.disc_type
  create_option        = "Empty"
  disk_size_gb         = each.value.disc_size
  tags                 = var.tag
}

# 挂载Linux虚拟机数据磁盘。
resource "azurerm_virtual_machine_data_disk_attachment" "linux_data_disk_attachment" {
  depends_on         = [azurerm_managed_disk.linux_data_disk]
  for_each           = { for s in local.vm_flat : format("%s%02d", s.component, s.index+1 ) => s if s.disc_size > 0 && s.type == "linux" }
  managed_disk_id    = azurerm_managed_disk.linux_data_disk[each.key].id
  virtual_machine_id = azurerm_linux_virtual_machine.vm[each.key].id
  lun                = "0"
  caching            = each.value.disc_type == "Premium_LRS" ? "None" : "ReadWrite"
}

# 启用Linux虚拟机备份。
resource "azurerm_backup_protected_vm" "backup_protected_linux_vm" {
  depends_on          = [azurerm_backup_policy_vm.backup_policy_vm]
  for_each            = { for s in local.vm_flat : format("%s%02d", s.component, s.index+1 ) => s if s.backup && s.type == "linux" }
  resource_group_name = "rg-${title(var.customer)}-${upper(var.env)}"
  recovery_vault_name = "rsv-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}"
  source_vm_id        = azurerm_linux_virtual_machine.vm[each.key].id
  backup_policy_id    = azurerm_backup_policy_vm.backup_policy_vm.id
}

# 创建Windows虚拟机。
resource "azurerm_windows_virtual_machine" "vm" {
  depends_on            = [azurerm_network_interface.nic, azurerm_availability_set.avset]
  for_each              = { for s in local.vm_flat : format("%s%02d", s.component, s.index+1 ) => s if s.type == "windows" }
  name                  = "vm-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}-${title(var.project)}-${each.key}"
  location              = var.location
  resource_group_name   = "rg-${title(var.customer)}-${upper(var.env)}"
  availability_set_id   = azurerm_availability_set.avset.id
  network_interface_ids = [azurerm_network_interface.nic[each.key].id]
  size                  = each.value.size
  computer_name         = "${title(var.customer)}-${upper(substr(var.env,0,1))}-${title(var.project)}-${each.key}"
  admin_username        = lookup(var.vm_auth, "user", "oper")
  admin_password        = lookup(var.vm_auth, "pass", "aGhQpYPQd9vzPH8k")
  tags                  = var.tag
  os_disk {
    name                 = "osdisk-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}-${title(var.project)}-${each.key}"
    caching              = each.value.disc_type == "Premium_LRS" ? "None" : "ReadWrite"
    storage_account_type = each.value.disc_type
  }
  source_image_reference {
    publisher = each.value.publisher
    offer     = each.value.offer
    sku       = each.value.sku
    version   = each.value.version
  }
  boot_diagnostics {}
}

# 创建Windows虚拟机数据磁盘。
resource "azurerm_managed_disk" "windows_data_disk" {
  depends_on           = [azurerm_windows_virtual_machine.vm]
  for_each             = { for s in local.vm_flat : format("%s%02d", s.component, s.index+1 ) => s if s.disc_size > 0 && s.type == "windows" }
  name                 = "disk-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}-${title(var.project)}-${each.key}"
  location             = var.location
  resource_group_name  = "rg-${title(var.customer)}-${upper(var.env)}"
  storage_account_type = each.value.disc_type
  create_option        = "Empty"
  disk_size_gb         = each.value.disc_size
  tags                 = var.tag
}

# 挂载Windows虚拟机数据磁盘。
resource "azurerm_virtual_machine_data_disk_attachment" "windows_data_disk_attachment" {
  depends_on         = [azurerm_managed_disk.windows_data_disk]
  for_each           = { for s in local.vm_flat : format("%s%02d", s.component, s.index+1 ) => s if s.disc_size > 0 && s.type == "windows" }
  managed_disk_id    = azurerm_managed_disk.windows_data_disk[each.key].id
  virtual_machine_id = azurerm_windows_virtual_machine.vm[each.key].id
  lun                = "0"
  caching            = each.value.disc_type == "Premium_LRS" ? "None" : "ReadWrite"
}

# 启用Windows虚拟机备份。
resource "azurerm_backup_protected_vm" "backup_protected_windows_vm" {
  depends_on          = [azurerm_backup_policy_vm.backup_policy_vm]
  for_each            = { for s in local.vm_flat : format("%s%02d", s.component, s.index+1 ) => s if s.backup && s.type == "windows" }
  resource_group_name = "rg-${title(var.customer)}-${upper(var.env)}"
  recovery_vault_name = "rsv-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}"
  source_vm_id        = azurerm_windows_virtual_machine.vm[each.key].id
  backup_policy_id    = azurerm_backup_policy_vm.backup_policy_vm.id
}

# 安装Windows虚拟机扩展插件。
resource "azurerm_virtual_machine_extension" "vm" {
  depends_on           = [azurerm_windows_virtual_machine.vm]
  for_each             = { for s in local.vm_flat : format("%s%02d", s.component, s.index+1 ) => s if s.type == "windows" }
  name                 = "WinRM"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm[each.key].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  tags                 = var.tag
  settings = <<SETTINGS
  {
    "fileUris": [ "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1" ],
    "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File ConfigureRemotingForAnsible.ps1"
  }
SETTINGS
}