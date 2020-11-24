# 将通过变量传入的虚拟机属性映射投影到每个变量都有单独元素的集合。
locals {
  vm_flat = flatten([
    for s in var.vm_spec : [
      for i in range(s.count) : {
        component              = s.component
        type                   = s.type
        backup                 = s.backup
        size                   = s.size
        publisher              = s.publisher
        offer                  = s.offer
        sku                    = s.sku
        version                = s.version
        vm_public              = s.vm_public
        ip_forwarding          = s.ip_forwarding
        accelerated_networking = s.accelerated_networking
        disc_type              = s.disc_type
        disc_size              = s.disc_size
        index                  = i
      }
    ]
  ])
}