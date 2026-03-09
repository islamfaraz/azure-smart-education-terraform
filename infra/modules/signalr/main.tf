# =============================================
# Azure SignalR Service — Real-time Collaboration
# Live classroom, chat, whiteboard, notifications
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

resource "azurerm_signalr_service" "main" {
  name                = "sigr-${var.name_prefix}-${var.unique_suffix}"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  sku {
    name     = var.environment == "prod" ? "Standard_S1" : "Free_F1"
    capacity = var.environment == "prod" ? 2 : 1
  }

  connectivity_logs_enabled = true
  messaging_logs_enabled    = true

  cors {
    allowed_origins = ["https://app.smarteducation.org"]
  }

  tags = var.tags
}

output "hostname" {
  value = azurerm_signalr_service.main.hostname
}

output "connection_string" {
  value     = azurerm_signalr_service.main.primary_connection_string
  sensitive = true
}

output "id" {
  value = azurerm_signalr_service.main.id
}
