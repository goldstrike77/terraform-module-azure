# 将通过变量传入的应用程序网关后端属性映射投影到每个变量都有单独元素的集合。
locals {
  agw_backend = flatten([
    for s in lookup(var.agw_spec, "backend", []) : [
      for k in s.settings : {
        fqdns    = s.fqdns
        protocol = k.protocol
        port     = k.port
      }
    ]
  ])
}