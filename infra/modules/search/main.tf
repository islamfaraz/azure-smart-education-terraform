# =============================================
# Azure Cognitive Search — Course & Content Search
# Full-text search across courses, materials, Q&A
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

resource "azurerm_search_service" "main" {
  name                = "search-${var.name_prefix}-${var.unique_suffix}"
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  sku                 = var.environment == "prod" ? "standard" : "free"
  replica_count       = var.environment == "prod" ? 2 : 1
  partition_count     = var.environment == "prod" ? 2 : 1

  tags = var.tags
}

output "endpoint" {
  value = "https://${azurerm_search_service.main.name}.search.windows.net"
}

output "primary_key" {
  value     = azurerm_search_service.main.primary_key
  sensitive = true
}

output "id" {
  value = azurerm_search_service.main.id
}
