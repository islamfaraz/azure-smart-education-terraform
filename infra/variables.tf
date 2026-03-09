# =============================================
# Variables — Azure Smart Education Hub
# =============================================

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "location" {
  description = "Azure region for resource deployment"
  type        = string
  default     = "eastus2"
}

variable "project_name" {
  description = "Project name used in resource naming"
  type        = string
  default     = "smartedu"
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default     = {}
}

variable "sql_admin_password" {
  description = "SQL Server administrator password — set via TF_VAR or pipeline secret"
  type        = string
  sensitive   = true
}

variable "aad_admin_object_id" {
  description = "Azure AD admin group object ID for SQL Server"
  type        = string
}
