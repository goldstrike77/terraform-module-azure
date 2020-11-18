# 将通过变量传入的负载均衡器属性映射投影到每个变量都有单独元素的集合。
locals {
  lb_flat = flatten([
    for s in var.vm_spec : [
      for i in range(s.count) : [
        for k in s.lb_spec : {
          component     = s.component
          nat           = k.nat
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

# 创建公共IP地址。
resource "azurerm_public_ip" "public_ip" {
  for_each            = { for s in local.lb_flat : s.component => s... if s.public && s.protocol != null }
  name                = "AZ-LB-WAN-${title(var.customer)}-${title(var.environment)}-${title(var.project)}-${each.key}"
  location            = var.location
  resource_group_name = "AZ-RG-${title(var.customer)}-${title(var.environment)}"
  sku                 = "Standard"
  allocation_method   = "Static"
  tags                = var.tag
}

# 创建公共负载均衡器。
resource "azurerm_lb" "public_lb" {
  depends_on          = [azurerm_public_ip.public_ip]
  name                = "AZ-LB-Public-${title(var.customer)}-${title(var.environment)}-${title(var.project)}"
  location            = var.location
  resource_group_name = "AZ-RG-${title(var.customer)}-${title(var.environment)}"
  sku                 = "Standard"
  tags                = var.tag
  dynamic "frontend_ip_configuration" {
    iterator = pub
    for_each = { for s in local.lb_flat : s.component => s... if s.public && s.protocol != null }
    content {
      name                 = "AZ-LB-IP-Public-${title(var.customer)}-${title(var.environment)}-${title(var.project)}-${pub.key}"
      public_ip_address_id = azurerm_public_ip.public_ip[pub.key].id
    }
  }
}

# 创建内部负载均衡器。
resource "azurerm_lb" "internal_lb" {
  name                = "AZ-LB-Internal-${title(var.customer)}-${title(var.environment)}-${title(var.project)}"
  location            = var.location
  resource_group_name = "AZ-RG-${title(var.customer)}-${title(var.environment)}"
  sku                 = "Standard"
  tags                = var.tag
  dynamic "frontend_ip_configuration" {
    iterator = pub
    for_each = { for s in local.lb_flat : s.component => s... if s.protocol != null }
    content {
      name                          = "AZ-LB-IP-Internal-${title(var.customer)}-${title(var.environment)}-${title(var.project)}-${pub.key}"
      subnet_id                     = var.subnet_id
      private_ip_address_allocation = "Dynamic"
    }
  }
}

# 创建公共负载均衡器后端池。
resource "azurerm_lb_backend_address_pool" "lb_backend_address_pool_public" {
  depends_on          = [azurerm_lb.public_lb]
  for_each            = { for s in local.lb_flat : s.component => s... if s.public && s.protocol != null }
  resource_group_name = "AZ-RG-${title(var.customer)}-${title(var.environment)}"
  loadbalancer_id     = azurerm_lb.public_lb.id
  name                = "AZ-LB-Backend-Public-${title(var.customer)}-${title(var.environment)}-${title(var.project)}-${each.value[0].component}"
}

# 创建内部负载均衡器后端池。
resource "azurerm_lb_backend_address_pool" "lb_backend_address_pool_internal" {
  depends_on          = [azurerm_lb.internal_lb]
  for_each            = { for s in local.lb_flat : s.component => s... if s.protocol != null }
  resource_group_name = "AZ-RG-${title(var.customer)}-${title(var.environment)}"
  loadbalancer_id     = azurerm_lb.internal_lb.id
  name                = "AZ-LB-Backend-Internal-${title(var.customer)}-${title(var.environment)}-${title(var.project)}-${each.value[0].component}"
}

# 创建公共负载均衡器后端池网卡关联。
resource "azurerm_network_interface_backend_address_pool_association" "network_interface_backend_address_pool_association_public" {
  depends_on              = [azurerm_lb.public_lb]
  for_each                = { for s in local.lb_flat : format("%s%02d", s.component, s.index+1) => s... if s.public && s.protocol != null }
  network_interface_id    = var.network_interface[each.key]
  ip_configuration_name   = "AZ-LAN-${title(var.customer)}-${title(var.environment)}-${title(var.project)}-${each.key}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend_address_pool_public[each.value[0].component].id
}

# 创建内部负载均衡器后端池网卡关联。
resource "azurerm_network_interface_backend_address_pool_association" "network_interface_backend_address_pool_association_internal" {
  depends_on              = [azurerm_lb.internal_lb]
  for_each                = { for s in local.lb_flat : format("%s%02d", s.component, s.index+1) => s... if s.protocol != null }
  network_interface_id    = var.network_interface[each.key]
  ip_configuration_name   = "AZ-LAN-${title(var.customer)}-${title(var.environment)}-${title(var.project)}-${each.key}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend_address_pool_internal[each.value[0].component].id
}

# 创建公共负载均衡器后端运行状况探测。
resource "azurerm_lb_probe" "lb_probe_public" {
  depends_on              = [azurerm_lb.public_lb]
  for_each                = { for s in local.lb_flat : format("%s-%s-%s", s.component, s.protocol, s.backend_port) => s... if s.public && s.protocol != null }
  resource_group_name     = "AZ-RG-${title(var.customer)}-${title(var.environment)}"
  loadbalancer_id         = azurerm_lb.public_lb.id
  name                    = "AZ-LB-Probe-Public-${title(var.customer)}-${title(var.environment)}-${title(var.project)}-${each.key}"
  protocol                = lower(each.value[0].protocol) == "tcp" ? "tcp" : null
  port                    = each.value[0].backend_port
}

# 创建内部负载均衡器后端运行状况探测。
resource "azurerm_lb_probe" "lb_probe_internal" {
  depends_on              = [azurerm_lb.internal_lb]
  for_each                = { for s in local.lb_flat : format("%s-%s-%s", s.component, s.protocol, s.backend_port) => s... if s.protocol != null }
  resource_group_name     = "AZ-RG-${title(var.customer)}-${title(var.environment)}"
  loadbalancer_id         = azurerm_lb.internal_lb.id
  name                    = "AZ-LB-Probe-Internal-${title(var.customer)}-${title(var.environment)}-${title(var.project)}-${each.key}"
  protocol                = lower(each.value[0].protocol) == "tcp" ? "tcp" : null
  port                    = each.value[0].backend_port
}

# 创建公共负载均衡器规则。
resource "azurerm_lb_rule" "lb_rule_public" {
  depends_on                     = [azurerm_lb.public_lb,azurerm_lb_probe.lb_probe_public]
  for_each                       = { for s in local.lb_flat : format("%s-%s-%s", s.component, s.protocol, s.backend_port) => s... if s.public && !s.nat && s.protocol != null }
  resource_group_name            = "AZ-RG-${title(var.customer)}-${title(var.environment)}"
  loadbalancer_id                = azurerm_lb.public_lb.id
  name                           = "AZ-LB-Rule-Public-${title(var.customer)}-${title(var.environment)}-${title(var.project)}-${each.key}"
  protocol                       = lower(each.value[0].protocol)
  frontend_port                  = each.value[0].frontend_port
  backend_port                   = each.value[0].backend_port
  probe_id                       = lower(each.value[0].protocol) == "tcp" ? azurerm_lb_probe.lb_probe_public[each.key].id : null
  backend_address_pool_id        = azurerm_lb_backend_address_pool.lb_backend_address_pool_public[each.value[0].component].id
  frontend_ip_configuration_name = "AZ-LB-IP-Public-${title(var.customer)}-${title(var.environment)}-${title(var.project)}-${each.value[0].component}"
}

# 创建内部负载均衡器规则。
resource "azurerm_lb_rule" "lb_rule_internal" {
  depends_on                     = [azurerm_lb.internal_lb,azurerm_lb_probe.lb_probe_internal]
  for_each                       = { for s in local.lb_flat : format("%s-%s-%s", s.component, s.protocol, s.backend_port) => s... if !s.nat && s.protocol != null }
  resource_group_name            = "AZ-RG-${title(var.customer)}-${title(var.environment)}"
  loadbalancer_id                = azurerm_lb.internal_lb.id
  name                           = "AZ-LB-Rule-Internal-${title(var.customer)}-${title(var.environment)}-${title(var.project)}-${each.key}"
  protocol                       = lower(each.value[0].protocol)
  frontend_port                  = each.value[0].frontend_port
  backend_port                   = each.value[0].backend_port
  probe_id                       = lower(each.value[0].protocol) == "tcp" ? azurerm_lb_probe.lb_probe_internal[each.key].id : null
  backend_address_pool_id        = azurerm_lb_backend_address_pool.lb_backend_address_pool_internal[each.value[0].component].id
  frontend_ip_configuration_name = "AZ-LB-IP-Internal-${title(var.customer)}-${title(var.environment)}-${title(var.project)}-${each.value[0].component}"
}

# 创建负载均衡器入站网络地址转换规则。
resource "azurerm_lb_nat_rule" "lb_nat_rule" {
  depends_on                     = [azurerm_lb.public_lb]
  for_each                       = { for s in local.lb_flat : format("%s-%s-%s", s.component, s.protocol, s.backend_port) => s... if s.nat && !s.public && s.protocol != null }
  resource_group_name            = "AZ-RG-${title(var.customer)}-${title(var.environment)}"
  loadbalancer_id                = azurerm_lb.public_lb.id
  name                           = "AZ-LB-NAT-Rule-${title(var.customer)}-${title(var.environment)}-${title(var.project)}-${each.key}"
  protocol                       = lower(each.value[0].protocol)
  frontend_port                  = each.value[0].frontend_port
  backend_port                   = each.value[0].backend_port
  frontend_ip_configuration_name ="AZ-LB-IP-Public-${title(var.customer)}-${title(var.environment)}-${title(var.project)}-${each.value[0].component}"
}