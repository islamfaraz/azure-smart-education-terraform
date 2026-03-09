# =============================================
# Azure App Service — Education Platform Web App
# Hosts the web application and API backend
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

variable "sql_connection" {
  type      = string
  sensitive = true
}

variable "cognitive_endpoint" {
  type = string
}

variable "cognitive_key" {
  type      = string
  sensitive = true
}

variable "redis_connection" {
  type      = string
  sensitive = true
}

variable "search_endpoint" {
  type = string
}

variable "search_key" {
  type      = string
  sensitive = true
}

variable "signalr_connection" {
  type      = string
  sensitive = true
}

# App Service Plan
resource "azurerm_service_plan" "main" {
  name                = "plan-${var.name_prefix}-${var.unique_suffix}"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  os_type             = "Linux"
  sku_name            = var.environment == "prod" ? "P1v3" : "B1"

  tags = var.tags
}

# App Service (Web App)
resource "azurerm_linux_web_app" "main" {
  name                = "app-${var.name_prefix}-${var.unique_suffix}"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  service_plan_id     = azurerm_service_plan.main.id
  https_only          = true

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on        = var.environment == "prod"
    ftps_state       = "Disabled"
    minimum_tls_version = "1.2"
    http2_enabled    = true

    application_stack {
      dotnet_version = "8.0"
    }
  }

  app_settings = {
    "ASPNETCORE_ENVIRONMENT"       = var.environment == "prod" ? "Production" : "Development"
    "ConnectionStrings__SqlDb"     = var.sql_connection
    "CognitiveServices__Endpoint"  = var.cognitive_endpoint
    "CognitiveServices__Key"       = var.cognitive_key
    "Redis__ConnectionString"      = var.redis_connection
    "Search__Endpoint"             = var.search_endpoint
    "Search__Key"                  = var.search_key
    "SignalR__ConnectionString"    = var.signalr_connection
  }

  tags = var.tags
}

# Autoscale for production
resource "azurerm_monitor_autoscale_setting" "main" {
  count               = var.environment == "prod" ? 1 : 0
  name                = "autoscale-${var.name_prefix}"
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  target_resource_id  = azurerm_service_plan.main.id

  profile {
    name = "default"

    capacity {
      default = 2
      minimum = 2
      maximum = 10
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.main.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
      }
      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.main.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT10M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }
      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
  }

  tags = var.tags
}

output "default_hostname" {
  value = azurerm_linux_web_app.main.default_hostname
}

output "app_id" {
  value = azurerm_linux_web_app.main.id
}

output "identity_principal_id" {
  value = azurerm_linux_web_app.main.identity[0].principal_id
}
