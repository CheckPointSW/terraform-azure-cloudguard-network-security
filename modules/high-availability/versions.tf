terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90.0"
    }
    azapi = {
      source = "Azure/azapi"
      version = "~> 2.7.0"
    }
    random = {
      version = "~> 3.6.0"
    }
  }
}
provider "azapi" {
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

provider "azurerm" {
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  features {}
}
