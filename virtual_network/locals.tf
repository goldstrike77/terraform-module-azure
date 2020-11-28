# 将通过变量传入的虚拟网络属性映射投影到每个变量都有单独元素的集合。
locals {
  vnet_flat = flatten([
    for s in var.vnet_spec[*] : [
      for k in var.vnet_spec[*] : {
        src                          = s.env == k.env ? null : s.env
        dst                          = k.env == s.env ? null : k.env
        customer                     = s.customer
        location                     = s.location
        allow_virtual_network_access = s.allow_virtual_network_access
        allow_forwarded_traffic      = s.allow_forwarded_traffic
        allow_gateway_transit        = s.allow_gateway_transit
      }
    ]
  ])
}