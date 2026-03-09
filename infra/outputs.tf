# =============================================
# Outputs — Azure Smart Education Hub
# =============================================

output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "app_service_url" {
  value = module.app_service.default_hostname
}

output "cognitive_endpoint" {
  value = module.cognitive_services.endpoint
}

output "sql_server_fqdn" {
  value = module.sql_database.server_fqdn
}

output "redis_hostname" {
  value = module.redis.hostname
}

output "search_endpoint" {
  value = module.search.endpoint
}

output "signalr_hostname" {
  value = module.signalr.hostname
}

output "cdn_endpoint" {
  value = module.cdn.endpoint_hostname
}
