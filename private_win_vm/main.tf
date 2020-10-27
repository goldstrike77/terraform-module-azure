module "subnet" {
  source               = "../subnet"
  resource_group_name  = "${var.resource_group_name}"
  location             = "${var.location}"
  virtual_network_name = "${var.virtual_network_name}"
  virtual_network_cidr = "${var.virtual_network_cidr}"
  virtual_network_dns  = "${var.virtual_network_dns}"
  nsg_name             = "${var.nsg_name}"
  nsgr_name            = "${var.nsgr_name}"
  nsgr_priority        = "${var.nsgr_priority}"
  nsgr_direction       = "${var.nsgr_direction}"
  nsgr_access          = "${var.nsgr_access}"
  nsgr_prot            = "${var.nsgr_prot}"
  nsgr_sour_port       = "${var.nsgr_sour_port}"
  nsgr_dest_port       = "${var.nsgr_dest_port}"
  nsgr_sour_addr       = "${var.nsgr_sour_addr}"
  nsgr_dest_addr       = "${var.nsgr_dest_addr}"
  subnet_names         = "${var.subnet_names}"
  subnet_prefixes      = "${var.subnet_prefixes}"
  tag                  = "${var.tag}"
}

resource "azurerm_availability_set" "avset" {
  name                         = "${var.project_name}-AVSET"
  depends_on                   = [module.subnet]
  location                     = "${var.location}"
  resource_group_name          = "${var.resource_group_name}"
  platform_fault_domain_count  = 2
  platform_update_domain_count = 5
  managed                      = true

  tags = {
    owner       = "${lookup(var.tag, "owner")}"
    email       = "${lookup(var.tag, "email")}"
    title       = "${lookup(var.tag, "title")}"
    department  = "${lookup(var.tag, "department")}"
    location    = "${lookup(var.tag, "location")}"
    project     = "${lookup(var.tag, "project")}"
    environment = "${lookup(var.tag, "environment")}"
  }
}

resource "azurerm_network_interface" "nic" {
  count               = "${length(var.win_vm_name)}"
  name                = "AZ-${var.win_vm_name[count.index]}-NIC"
  depends_on          = [azurerm_availability_set.avset]
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  tags = {
    owner       = "${lookup(var.tag, "owner")}"
    email       = "${lookup(var.tag, "email")}"
    title       = "${lookup(var.tag, "title")}"
    department  = "${lookup(var.tag, "department")}"
    location    = "${lookup(var.tag, "location")}"
    project     = "${lookup(var.tag, "project")}"
    environment = "${lookup(var.tag, "environment")}"
  }

  ip_configuration {
    name                          = "AZ-IP-${var.win_vm_name[count.index]}-LAN"
    subnet_id                     = "${module.subnet.azurerm_subnet_id}"
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_virtual_machine" "vm" {
  count                 = "${length(var.win_vm_name)}"
  name                  = "${var.win_vm_name[count.index]}"
  depends_on            = [azurerm_network_interface.nic", "azurerm_availability_set.avset]
  location              = "${var.location}"
  resource_group_name   = "${var.resource_group_name}"
  availability_set_id   = "${azurerm_availability_set.avset.id}"
  network_interface_ids = ["${element(azurerm_network_interface.nic.*.id, count.index)}"]
  vm_size               = "${var.win_vm_size[count.index]}"

  storage_os_disk {
    name              = "${var.win_vm_name[count.index]}-OS-Disc0"
    caching           = "ReadWrite"
    os_type           = "windows"
    create_option     = "FromImage"
    managed_disk_type = "${var.win_disc_type[count.index]}"
  }

  storage_data_disk {
    name              = "${var.win_vm_name[count.index]}-DT-Disc0"
    managed_disk_type = "${var.win_disc_type[count.index]}"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "${var.win_disc_size[count.index]}"
  }

  storage_image_reference {
    publisher = "${var.win_vm_publisher}"
    offer     = "${var.win_vm_offer}"
    sku       = "${var.win_vm_sku}"
    version   = "${var.win_vm_version}"
  }

  os_profile {
    computer_name  = "${var.win_vm_name[count.index]}"
    admin_username = "${var.vm_admin_username}"
    admin_password = "${var.vm_admin_password}"
  }

  os_profile_windows_config {
    provision_vm_agent = "true"
  }

  tags = {
    owner       = "${lookup(var.tag, "owner")}"
    email       = "${lookup(var.tag, "email")}"
    title       = "${lookup(var.tag, "title")}"
    department  = "${lookup(var.tag, "department")}"
    location    = "${lookup(var.tag, "location")}"
    project     = "${lookup(var.tag, "project")}"
    environment = "${lookup(var.tag, "environment")}"
  }
}

resource "azurerm_virtual_machine_extension" "vm" {
  count                = "${length(var.win_vm_name)}"
  name                 = "WinRM"
  depends_on           = [azurerm_virtual_machine.vm]
  location             = "${var.location}"
  resource_group_name  = "${var.resource_group_name}"
  virtual_machine_name = "${var.win_vm_name[count.index]}"
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.8"

  settings = <<WINRM_SETTINGS
  {
    "fileUris": [ "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1" ],
    "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -File ConfigureRemotingForAnsible.ps1"
  }
WINRM_SETTINGS

  settings = <<TIMEZONE_SETTINGS
  {
    "commandToExecute": "powershell.exe Set-TimeZone -Name "China Standard Time""
  }
TIMEZONE_SETTINGS
}
