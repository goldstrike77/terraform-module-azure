#### 创建时间大致需要一小时，不知道如何控制活动目录域服务托管自动关联创建负载均衡器，公共地址和实例网卡，部署模板接口文档里没有相关参数，谁知道的教我一下，一百元红包奖励。

#### Requirements
- [Grant Azure Active Directory permissions for Service Principal.](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/guides/service_principal_configuration)
- [Create required Azure AD resources.](https://docs.microsoft.com/en-us/azure/active-directory-domain-services/template-create-instance)

#### Usage
```terraform
module "network_security_group" {
  source               = ""
  location             = var.location
  env                  = var.env
  project              = var.project
  customer             = var.customer
  tag                  = var.tag
  security_group_rules = var.addds_security_group_rules
}

module "subnet" {
  depends_on         = [module.network_security_group]
  source             = ""
  location           = var.location
  env                = var.env
  project            = var.project
  customer           = var.customer
  tag                = var.tag
  subnet_prefixes    = var.aadds_subnet_prefixes
  security_group_ass = true
  security_group_id  = module.network_security_group.net_security_group_id
}

module "aadds" {
  depends_on = [module.subnet]
  source     = ""
  location   = var.location
  env        = var.env
  customer   = var.customer
  aadds_spec = var.aadds_spec
}
```

#### Variables
```terraform
variable "geography" {}

variable "location" {
  default = "chinanorth2"
}

variable "env" {
  default = "pub"
}

variable "project" {
  default = "aadds"
}

variable "customer" {
  default = "Learn"
}

variable "aadds_subnet_prefixes" {
  default = "10.0.0.0/28"
}

variable "aadds_spec" {
  default = {
    domain = "goldstrike77.partner.onmschina.cn"
    type   = "FullySynced"
    sku    = "Standard"
  }
}

variable "addds_security_group_rules" {
  default = {
    IBA-AzureAD-TCP = {
      priority  = "101"
      direction = "Inbound"
      access    = "Allow"
      protocol  = "Tcp"
      source_address_prefix      = "AzureActiveDirectoryDomainServices"
      destination_address_prefix = "*"
      source_port_range          = "*"
      destination_port_ranges    = ["443","5986"]
    }
  }
}

variable "tag" {
  type = map
  default = {
    location    = "chinanorth2"
    environment = "Pub"
    customer    = "Learn"
    owner       = "suzhetao"
    email       = "suzhetao@gmail.com"
    title       = "Engineer"
    department  = "IS"
  }
}
```