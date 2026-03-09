# =============================================
# Azure SQL Database — Structured Learning Data
# Course catalog, student progress, assessments
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

variable "administrator_password" {
  type      = string
  sensitive = true
  description = "SQL Server administrator password — pass via pipeline variable or Key Vault"
}

variable "aad_admin_object_id" {
  type        = string
  description = "Azure AD admin group object ID for SQL Server"
}

resource "azurerm_mssql_server" "main" {
  name                         = "sql-${var.name_prefix}-${var.unique_suffix}"
  resource_group_name          = var.resource_group.name
  location                     = var.resource_group.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = var.administrator_password
  minimum_tls_version          = "1.2"

  azuread_administrator {
    login_username = "AzureAD Admin"
    object_id      = var.aad_admin_object_id
  }

  tags = var.tags
}

resource "azurerm_mssql_database" "education" {
  name        = "sqldb-education"
  server_id   = azurerm_mssql_server.main.id
  collation   = "SQL_Latin1_General_CP1_CI_AS"
  sku_name    = var.environment == "prod" ? "S2" : "Basic"
  max_size_gb = var.environment == "prod" ? 50 : 2

  short_term_retention_policy {
    retention_days = var.environment == "prod" ? 35 : 7
  }

  tags = var.tags
}

# Allow Azure services to access the SQL server
resource "azurerm_mssql_firewall_rule" "azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

output "server_fqdn" {
  value = azurerm_mssql_server.main.fully_qualified_domain_name
}

output "connection_string" {
  value     = "Server=tcp:${azurerm_mssql_server.main.fully_qualified_domain_name},1433;Database=${azurerm_mssql_database.education.name};Encrypt=true;TrustServerCertificate=false;"
  sensitive = true
}

output "database_name" {
  value = azurerm_mssql_database.education.name
}
