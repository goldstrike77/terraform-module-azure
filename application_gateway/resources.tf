# 获取应用程序网关子网编号。
data "azurerm_subnet" "subnet_agw" {
  name                 = "snet-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}-application-gateway"
  resource_group_name  = "rg-${title(var.customer)}-${upper(var.env)}"
  virtual_network_name = "vnet-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}"
}

# 创建公共IP地址。
resource "azurerm_public_ip" "public_ip_agw" {
  count               = lookup(var.agw_spec, "public", false) ? 1 : 0
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
  enable_http2        = lookup(var.agw_spec, "enable_http2", false)
  tags                = var.tag
  sku {
    name = lookup(var.agw_spec, "name", "Standard_Small")
    tier = lookup(var.agw_spec, "tier", "Standard")
  }
  autoscale_configuration {
    min_capacity = lookup(var.agw_spec, "capacity.min", 1)
    max_capacity = lookup(var.agw_spec, "capacity.max", 3)
  }
  frontend_ip_configuration {
    name                          = "ip-agw-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}-${title(var.project)}-frontend-ip"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = lookup(var.agw_spec, "public", false) ? azurerm_public_ip.public_ip_agw.id : null
  }
  gateway_ip_configuration {
    name      = "agw-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}-${title(var.project)}-configuration"
    subnet_id = data.azurerm_subnet.subnet_agw.id
  }
  dynamic "frontend_port" {
    for_each = lookup(var.agw_spec, "listener", [])
    content {
      name = frontend_port.value[name]
      port = frontend_port.value[frontend_port]
    }
  }
  dynamic "http_listener" {
    for_each = lookup(var.agw_spec, "listener", [])
    content {
      name                           = http_listener.value[name]
      frontend_ip_configuration_name = "ip-agw-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}-${title(var.project)}-frontend-ip"
      frontend_port_name             = http_listener.value[frontend_port]
      host_names                     = http_listener.value[fqdn]
      protocol                       = http_listener.value[http_listener.value[name]]
    }
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