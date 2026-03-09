# =============================================
# Main — Azure Smart Education Hub
# Orchestrates all modules
# =============================================

locals {
  unique_suffix = substr(md5("${var.project_name}-${var.environment}"), 0, 6)
  name_prefix   = "${var.project_name}-${var.environment}"

  default_tags = merge(var.tags, {
    Environment = var.environment
    Project     = "SmartEducationHub"
    ManagedBy   = "Terraform"
  })
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-${local.name_prefix}"
  location = var.location
  tags     = local.default_tags
}

# --- Modules ---

module "cognitive_services" {
  source         = "./modules/cognitive"
  resource_group = azurerm_resource_group.main
  name_prefix    = local.name_prefix
  unique_suffix  = local.unique_suffix
  environment    = var.environment
  tags           = local.default_tags
}

module "sql_database" {
  source         = "./modules/sql"
  resource_group = azurerm_resource_group.main
  name_prefix    = local.name_prefix
  unique_suffix  = local.unique_suffix
  environment    = var.environment
  tags           = local.default_tags
}

module "app_service" {
  source              = "./modules/appservice"
  resource_group      = azurerm_resource_group.main
  name_prefix         = local.name_prefix
  unique_suffix       = local.unique_suffix
  environment         = var.environment
  tags                = local.default_tags
  sql_connection      = module.sql_database.connection_string
  cognitive_endpoint  = module.cognitive_services.endpoint
  cognitive_key       = module.cognitive_services.primary_key
  redis_connection    = module.redis.connection_string
  search_endpoint     = module.search.endpoint
  search_key          = module.search.primary_key
  signalr_connection  = module.signalr.connection_string
}

module "redis" {
  source         = "./modules/redis"
  resource_group = azurerm_resource_group.main
  name_prefix    = local.name_prefix
  unique_suffix  = local.unique_suffix
  environment    = var.environment
  tags           = local.default_tags
}

module "search" {
  source         = "./modules/search"
  resource_group = azurerm_resource_group.main
  name_prefix    = local.name_prefix
  unique_suffix  = local.unique_suffix
  environment    = var.environment
  tags           = local.default_tags
}

module "signalr" {
  source         = "./modules/signalr"
  resource_group = azurerm_resource_group.main
  name_prefix    = local.name_prefix
  unique_suffix  = local.unique_suffix
  environment    = var.environment
  tags           = local.default_tags
}

module "cdn" {
  source              = "./modules/cdn"
  resource_group      = azurerm_resource_group.main
  name_prefix         = local.name_prefix
  unique_suffix       = local.unique_suffix
  environment         = var.environment
  tags                = local.default_tags
  app_service_hostname = module.app_service.default_hostname
}
