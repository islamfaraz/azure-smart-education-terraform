# =============================================
# Azure Cognitive Services — AI/ML for Education
# Text Analytics, Translator, Speech Services
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

# Cognitive Services — Multi-service (Text Analytics + Translator + Language)
resource "azurerm_cognitive_account" "main" {
  name                  = "cog-${var.name_prefix}-${var.unique_suffix}"
  location              = var.resource_group.location
  resource_group_name   = var.resource_group.name
  kind                  = "CognitiveServices"
  sku_name              = var.environment == "prod" ? "S0" : "F0"
  custom_subdomain_name = "smartedu-${var.unique_suffix}"

  network_acls {
    default_action = var.environment == "prod" ? "Deny" : "Allow"
  }

  tags = var.tags
}

output "endpoint" {
  value = azurerm_cognitive_account.main.endpoint
}

output "primary_key" {
  value     = azurerm_cognitive_account.main.primary_access_key
  sensitive = true
}

output "id" {
  value = azurerm_cognitive_account.main.id
}
