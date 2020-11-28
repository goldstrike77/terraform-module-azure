#### Usage
```hcl
module "network_security_group" {
  count                = var.security_group_ass ? 1 : 0
  source               = ""
  location             = var.location
  env                  = var.env
  project              = var.project
  customer             = var.customer
  tag                  = var.tag
  security_group_rules = var.security_group_rules
}

module "subnet" {
  depends_on         = [module.network_security_group]
  source             = ""
  location           = var.location
  env                = var.env
  project            = var.project
  customer           = var.customer
  tag                = var.tag
  subnet_prefixes    = var.subnet_prefixes
  security_group_ass = var.security_group_ass
  security_group_id  = ( var.security_group_ass ? module.network_security_group[0].net_security_group_id : 0 )
}

module "virtual_machine" {
  depends_on = [module.subnet]
  source     = ""
  location   = var.location
  env        = var.env
  project    = var.project
  customer   = var.customer
  tag        = var.tag
  vm_auth    = var.vm_auth
  vm_spec    = var.vm_spec
  vm_backup  = var.vm_backup
}

module "lb" {
  depends_on        = [module.virtual_machine]
  source            = ""
  location          = var.location
  env               = var.env
  project           = var.project
  customer          = var.customer
  tag               = var.tag
  subnet_id         = module.subnet.azurerm_subnet_id
  network_interface = module.virtual_machine.azurerm_network_interface
  lb_spec           = var.vm_spec
}
```

#### Variables
```hcl
variable "geography" {}

variable "location" {
  default = "chinanorth2"
}

variable "env" {
  default = "prd"
}

variable "project" {
  default = "P1"
}

variable "customer" {
  default = "Learn"
}

variable "subnet_prefixes" {
  default = "10.10.2.0/24"
}

variable "security_group_ass" {
  type    = bool
  default = true
}

variable "security_group_rules" {
  default = {
    IBA-REMOTE-TCP = {
      priority  = "101"
      direction = "Inbound"
      access    = "Allow"
      protocol  = "Tcp"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "*"
      source_port_range          = "*"
      destination_port_ranges    = ["22","3389","5986"]
    }
    IBA-HTTP-TCP = {
      priority  = "111"
      direction = "Inbound"
      access    = "Allow"
      protocol  = "Tcp"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      source_port_range          = "*"
      destination_port_ranges    = ["80","8080"]
    }
    IBA-HTTPS-TCP = {
      priority  = "121"
      direction = "Inbound"
      access    = "Allow"
      protocol  = "Tcp"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      source_port_range          = "*"
      destination_port_ranges    = ["443","6443","7443","8443"]
    }
    IBA-METRICS-TCP = {
      priority  = "131"
      direction = "Inbound"
      access    = "Allow"
      protocol  = "Tcp"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "*"
      source_port_range          = "*"
      destination_port_range     = "9000-9999"
    }
    IBA-LB-ALL = {
      priority  = "201"
      direction = "Inbound"
      access    = "Allow"
      protocol  = "*"
      source_address_prefix      = "AzureLoadBalancer"
      destination_address_prefix = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
    }
    IBD-VirtualNetwork-ALL = {
      priority  = "4096"
      direction = "Inbound"
      access    = "Deny"
      protocol  = "*"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
    }
  }
}

variable "vm_auth" {
  default = {
    user = "oper"
    pass = "Passw0rd"
  }
}

variable "vm_backup" {
  default = {
    frequency = "daily"
    time      = "23:00"
    timezone  = "China Standard Time"
    count     = 7
  }
}

variable "vm_spec" {
  default = [
    {
      component              = "app"
      type                   = "linux"
      size                   = "Standard_B1ls"
      publisher              = "OpenLogic"
      offer                  = "CentOS"
      sku                    = "7_8"
      version                = "latest"
      backup                 = false
      vm_public              = false
      ip_forwarding          = false
      accelerated_networking = false
      disc_type              = "Standard_LRS"
      disc_size              = 0
      count                  = 1
      lb_spec                = []
    },
    {
      component              = "web"
      type                   = "linux"
      size                   = "Standard_B1ls"
      publisher              = "OpenLogic"
      offer                  = "CentOS"
      sku                    = "7_8"
      version                = "latest"
      backup                 = false
      vm_public              = false
      ip_forwarding          = false
      accelerated_networking = false
      disc_type              = "Standard_LRS"
      disc_size              = 0
      count                  = 0
      lb_spec                = [
        {
           nat           = false
           public        = false
           protocol      = "tcp"
           frontend_port = "80"
           backend_port  = "80"
        },
        {
           nat           = false
           public        = false
           protocol      = "tcp"
           frontend_port = "443"
           backend_port  = "443"
        }]
    }
  ]
}

variable "tag" {
  type = map
  default = {
    location    = "chinanorth2"
    environment = "Prd"
    customer    = "Learn"
    project     = "P1"
    owner       = "Somebody"
    email       = "suzhetao@gmail.com"
    title       = "Engineer"
    department  = "IS"
  }
}
```