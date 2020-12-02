# 创建Redis缓存。
resource "azurerm_redis_cache" "redis_cache" {
  for_each            = var.redis_spec
  name                = "redis-${title(var.customer)}-${upper(var.env)}-${lower(var.location)}-${title(var.project)}-${title(each.key)}"
  location            = var.location
  resource_group_name = "rg-${title(var.customer)}-${upper(var.env)}"
  capacity            = lookup(each.value, "capacity", 1)
  family              = title(lookup(each.value, "sku", "")) == "Premium" ? "P" : "C"
  sku_name            = title(lookup(each.value, "sku", "Standard"))
  enable_non_ssl_port = lookup(each.value, "enable_non_ssl", false)
  minimum_tls_version = lookup(each.value, "enable_non_ssl", false) ? null : "1.2"
  shard_count         = title(lookup(each.value, "sku", "")) == "Premium" ? lookup(each.value, "shard_count", 1000) : null
  tags                = var.tag
  redis_configuration {
    enable_authentication = lookup(each.value, "authentication", true)
  }
}

# 创建Redis缓存防火墙规则。
resource "azurerm_redis_firewall_rule" "redis_firewall_rule" {
  for_each            = var.redis_spec
  name                = "redis_firewall_${title(each.key)}"
  redis_cache_name    = azurerm_redis_cache.redis_cache[each.key].name
  resource_group_name = "rg-${title(var.customer)}-${upper(var.env)}"
  start_ip            = lookup(each.value, "start_ip", "0.0.0.0")
  end_ip              = lookup(each.value, "end_ip", "0.0.0.0")
}