# 获取应用程序网关子网编号。
data "azurerm_subnet" "subnet_agw" {
  name                 = "snet-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}-application-gateway"
  resource_group_name  = "rg-${title(var.customer)}-${upper(var.env)}"
  virtual_network_name = "vnet-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}"
}

# 创建公共IP地址。
resource "azurerm_public_ip" "public_ip_agw" {
  count               = lookup(var.agw_spec, "public", false) ? 1 : 0
  name                = "pip-agw-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}"
  location            = var.location
  resource_group_name = "rg-${title(var.customer)}-${upper(var.env)}"
  sku                 = "Standard"
  allocation_method   = "Static"
  tags                = var.tag
}

# 创建应用程序网关。
resource "azurerm_application_gateway" "application_gateway" {
  depends_on          = [data.azurerm_subnet.subnet_agw,azurerm_public_ip.public_ip_agw]
  name                = "agw-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}"
  resource_group_name = "rg-${title(var.customer)}-${upper(var.env)}"
  location            = var.location
  enable_http2        = lookup(var.agw_spec, "enable_http2", false)
  tags                = var.tag
  sku {
    name     = lookup(var.agw_spec, "name", "Standard_Small")
    tier     = lookup(var.agw_spec, "tier", "Standard")
    capacity = 2
  }
  /*
  autoscale_configuration {
    min_capacity = lookup(var.agw_spec, "capacity.min", 0)
    max_capacity = lookup(var.agw_spec, "capacity.max", 3)
  }
  */
  frontend_ip_configuration {
    name                          = "ip-agw-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}-frontend-ip"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = lookup(var.agw_spec, "public", false) ? azurerm_public_ip.public_ip_agw[0].id : null
  }
  gateway_ip_configuration {
    name      = "agw-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}-cfg"
    subnet_id = data.azurerm_subnet.subnet_agw.id
  }
  dynamic "frontend_port" {
    iterator = pub
    for_each = lookup(var.agw_spec, "listener", [])
    content {
      name = "agw-frontend-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}-${pub.value.port}"
      port = pub.value.port
    }
  }
  dynamic "http_listener" {
    iterator = pub
    for_each = lookup(var.agw_spec, "listener", [])
    content {
      name                           = "agw-listener-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}-${pub.value.protocol}"
      frontend_ip_configuration_name = "ip-agw-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}-frontend-ip"
      frontend_port_name             = "agw-frontend-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}-${pub.value.port}"
      protocol                       = pub.value.protocol
    }
  }
  dynamic "backend_address_pool" {
    iterator = pub
    for_each = { for s in local.agw_backend : s.fqdns => s... if s.fqdns != null }
    content {
      name  = "agw-backend-address-pool-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}-${pub.key}"
      fqdns = [pub.key]
    }
  }
  dynamic "backend_http_settings" {
    iterator = pub
    for_each = { for s in local.agw_backend : format("%s-%s", s.fqdns, s.port) => s... if s.fqdns != null }
    content {
      name                  = "agw-backend-http-settings-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}-${pub.key}"
      cookie_based_affinity = "Disabled"
      port                  = pub.value[0].port
      protocol              = pub.value[0].protocol
      request_timeout       = 60
    }
  }
  dynamic "request_routing_rule" {
    iterator = pub
    for_each = { for s in local.agw_backend : format("%s-%s", s.fqdns, s.port) => s... if s.fqdns != null }
    content {
      name                       = "agw-request-routing-rule-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}-${pub.key}"
      rule_type                  = "Basic"
      http_listener_name         = "agw-listener-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}-${pub.value[0].protocol}"
      backend_address_pool_name  = "agw-backend-address-pool-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}-${pub.value[0].fqdns}"
      backend_http_settings_name = "agw-backend-http-settings-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}-${pub.key}"
    }
  }
}