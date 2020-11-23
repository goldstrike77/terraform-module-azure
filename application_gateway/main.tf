# 将通过变量传入的应用程序网关属性映射投影到每个变量都有单独元素的集合。
locals {
  agw_flat = flatten([
    for s in var.agw_spec : [
      for i in range(s.count) : [
        for k in s.lb_spec : {
          component     = s.component
          public        = k.public
          protocol      = k.protocol
          frontend_port = k.frontend_port
          backend_port  = k.backend_port
          index         = i
        }
      ]
    ]
  ])
}

# 获取应用程序网关子网编号。
data "azurerm_subnet" "subnet_agw" {
  name                 = "snet-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}-application-gateway"
  resource_group_name  = "rg-${title(var.customer)}-${upper(var.env)}"
  virtual_network_name = "vnet-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}"
}

# 创建公共IP地址。
resource "azurerm_public_ip" "public_ip_agw" {
  count               = var.agw_public ? 1 : 0
  name                = "pip-agw-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}-${title(var.project)}"
  location            = var.location
  resource_group_name = "rg-${title(var.customer)}-${upper(var.env)}"
  sku                 = "Standard"
  allocation_method   = "Static"
  tags                = var.tag
}

# 创建应用程序网关。
resource "azurerm_application_gateway" "application_gateway" {
  depends_on          = [azurerm_subnet.subnet_agw,azurerm_lb.public_ip_agw]
  name                = "agw-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}-${title(var.project)}"
  resource_group_name = "rg-${title(var.customer)}-${upper(var.env)}"
  location            = var.location
  enable_http2        = true
  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 2
  }
  gateway_ip_configuration {
    name      = "agw-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}-${title(var.project)}-configuration"
    subnet_id = data.azurerm_subnet.subnet_agw.id
  }
  frontend_ip_configuration {
    name                          = "ip-agw-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}-${title(var.project)}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.agw_public ? azurerm_public_ip.public_ip_agw.id : null
  }
  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }
  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/path1/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  dynamic "http_listener" {
    iterator = pub
    for_each = { for s in local.agw_flat : s.component => s... if s.public && s.protocol != null }
    content {
        name                           = "%{ if http_listener.value.protocol == "https" }${http_listener.value.fqdn}-${http_listener.value.port}-${local.https_listener_name}%{ else }${http_listener.value.fqdn}-${local.http_listener_name}%{ endif }"  
        frontend_ip_configuration_name = "ip-agw-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}-${title(var.project)}"
        frontend_port_name             = http_listener.value.port
        host_name                      = http_listener.value.fqdn
        protocol                       = upper(http_listener.value.protocol)
        ssl_certificate_name           = "%{ if http_listener.value.protocol == "https" }${data.azurerm_key_vault_secret.cert_fe.name}%{ endif }" 
      }
  }
  dynamic "request_routing_rule" {
    iterator = pub
    for_each = { for s in local.agw_flat : s.component => s... if s.public && s.protocol != null }
    content {
        name                        = "%{ if request_routing_rule.value.protocol == "https" }${request_routing_rule.value.fqdn}-${request_routing_rule.value.port}%{ else }${request_routing_rule.value.fqdn}-redirect%{ endif }"  
        rule_type                   = "Basic"
        http_listener_name          = "%{ if request_routing_rule.value.protocol == "https" }${request_routing_rule.value.fqdn}-${request_routing_rule.value.port}-${local.https_listener_name}%{ else }${request_routing_rule.value.fqdn}-${local.http_listener_name}%{ endif }"
        backend_address_pool_name   = "%{ if request_routing_rule.value.protocol == "https" }${request_routing_rule.value.fqdn}%{ endif }" 
        backend_http_settings_name  = "%{ if request_routing_rule.value.protocol == "https" }${request_routing_rule.value.fqdn}-${local.backend_https_settings_name}%{ endif }" 
    }
  }
}