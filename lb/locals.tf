# 将通过变量传入的负载均衡器属性映射投影到每个变量都有单独元素的集合。
locals {
  lb_flat = flatten([
    for s in var.lb_spec : [
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