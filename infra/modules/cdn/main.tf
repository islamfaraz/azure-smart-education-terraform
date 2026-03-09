# =============================================
# Azure CDN — Static Content Delivery
# Course videos, images, documents globally cached
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

variable "app_service_hostname" {
  description = "App Service hostname to use as origin"
  type        = string
}

resource "azurerm_cdn_profile" "main" {
  name                = "cdn-${var.name_prefix}-${var.unique_suffix}"
  location            = "global"
  resource_group_name = var.resource_group.name
  sku                 = var.environment == "prod" ? "Standard_Microsoft" : "Standard_Microsoft"

  tags = var.tags
}

resource "azurerm_cdn_endpoint" "main" {
  name                = "cdnep-${var.name_prefix}-${var.unique_suffix}"
  profile_name        = azurerm_cdn_profile.main.name
  location            = "global"
  resource_group_name = var.resource_group.name
  is_http_allowed     = false
  is_https_allowed    = true

  origin {
    name      = "appservice-origin"
    host_name = var.app_service_hostname
  }

  delivery_rule {
    name  = "EnforceHTTPS"
    order = 1

    request_scheme_condition {
      operator     = "Equal"
      match_values = ["HTTP"]
    }

    url_redirect_action {
      redirect_type = "Found"
      protocol      = "Https"
    }
  }

  tags = var.tags
}

output "endpoint_hostname" {
  value = azurerm_cdn_endpoint.main.fqdn
}

output "profile_id" {
  value = azurerm_cdn_profile.main.id
}
