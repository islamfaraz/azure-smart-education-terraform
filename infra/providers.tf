# =============================================
# Azure Smart Education Hub — Provider Config
# Terraform + Azure — Remote State on Storage
# =============================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstate"
    container_name       = "tfstate"
    key                  = "smart-education-hub.tfstate"
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_deleted_secrets_on_destroy = false
      recover_soft_deleted_secrets          = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}
