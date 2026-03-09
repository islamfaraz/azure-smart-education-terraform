# =============================================
# Azure Cache for Redis — Session & Content Cache
# Low-latency caching for course content & sessions
# =============================================

variable "resource_group" {
  description = "Resource group object"
}

variable "name_prefix" {
  type = string
}

variable "unique_suffix" {
  type = string
}

variable "environment" {
  type = string
}

variable "tags" {
  type = map(string)
}

resource "azurerm_redis_cache" "main" {
  name                = "redis-${var.name_prefix}-${var.unique_suffix}"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  capacity            = var.environment == "prod" ? 1 : 0
  family              = var.environment == "prod" ? "P" : "C"
  sku_name            = var.environment == "prod" ? "Premium" : "Basic"
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"

  redis_configuration {
    maxmemory_policy = "allkeys-lru"
  }

  tags = var.tags
}

output "hostname" {
  value = azurerm_redis_cache.main.hostname
}

output "connection_string" {
  value     = azurerm_redis_cache.main.primary_connection_string
  sensitive = true
}

output "id" {
  value = azurerm_redis_cache.main.id
}
