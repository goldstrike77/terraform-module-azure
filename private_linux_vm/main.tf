resource "azurerm_availability_set" "avset" {
  name                         = "AZ-AVset-${title(var.customer)}-${lower(var.environment)}-${title(var.project)}"
  location                     = var.location
  resource_group_name          = "AZ-RG-${title(var.customer)}-${lower(var.environment)}"
  platform_fault_domain_count  = 2
  platform_update_domain_count = 5
  managed                      = true
  tags                         = {
    location    = lower(var.location)
    environment = lower(var.environment)
    project     = var.project
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
  count               = "length(var.linux_vm_name)"
  name                = "NIC-var.linux_vm_name[count.index]"
  location            = var.location
  resource_group_name = "AZ-RG-${title(var.customer)}-${lower(var.environment)}"
  tags                = {
    location    = lower(var.location)
    environment = lower(var.environment)
    project     = var.project
    customer    = title(var.customer)
    owner       = lookup(var.tag, var.tag.owner, "somebody")
    email       = lookup(var.tag, var.tag.email, "somebody@mail.com")
    title       = lookup(var.tag, var.tag.title, "Engineer")
    department  = lookup(var.tag, var.tag.department, "IS")
    costcenter  = lookup(var.tag, var.tag.costcenter, "xx")
    requestor   = lookup(var.tag, var.tag.requestor, "somebody@mail.com")
  }
  ip_configuration {
    name                          = "LAN-${title(var.customer)}-${lower(var.environment)}-${title(var.project)}[count.index]"
    subnet_id                     = "module.subnet.azurerm_subnet_id"
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_virtual_machine" "vm" {
  count                 = "length(var.linux_vm_name)"
  name                  = ${title(var.customer)}-${lower(var.environment)}-${title(var.project)}-[count.index]
  depends_on            = [azurerm_network_interface.nic, azurerm_availability_set.avset]
  location              = "var.location"
  resource_group_name   = "var.resource_group_name"
  availability_set_id   = "azurerm_availability_set.avset.id"
  network_interface_ids = ["element(azurerm_network_interface.nic.*.id, count.index)"]
  vm_size               = "var.linux_vm_size[count.index]"
  storage_os_disk {
    name              = "var.linux_vm_name[count.index]}-OS-Disc0"
    caching           = "ReadWrite"
    os_type           = "linux"
    create_option     = "FromImage"
    managed_disk_type = "var.linux_disc_type[count.index]"
  }
  storage_data_disk {
    name              = "var.linux_vm_name[count.index]}-DT-Disc0"
    managed_disk_type = "var.linux_disc_type[count.index]"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "var.linux_disc_size[count.index]"
  }
  storage_image_reference {
    publisher = "var.linux_vm_publisher"
    offer     = "var.linux_vm_offer"
    sku       = "var.linux_vm_sku"
    version   = "var.linux_vm_version"
  }
  os_profile {
    computer_name  = "var.linux_vm_name[count.index]"
    admin_username = "var.vm_admin_username"
    admin_password = "var.vm_admin_password"
  }
  os_profile_linux_config {
    disable_password_authentication = "false"
    ssh_keys {
      path     = "/home/var.vm_admin_username/.ssh/authorized_keys"
      key_data = "var.linux_vm_sshcert"
    }
  }
  tags                = {
    location    = lower(var.location)
    environment = lower(var.environment)
    project     = var.project
    customer    = title(var.customer)
    owner       = lookup(var.tag, var.tag.owner, "somebody")
    email       = lookup(var.tag, var.tag.email, "somebody@mail.com")
    title       = lookup(var.tag, var.tag.title, "Engineer")
    department  = lookup(var.tag, var.tag.department, "IS")
    costcenter  = lookup(var.tag, var.tag.costcenter, "xx")
    requestor   = lookup(var.tag, var.tag.requestor, "somebody@mail.com")
  }
}