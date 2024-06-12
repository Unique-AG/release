terraform {
  required_version = ">= 1.8.1"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.105.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = ">= 1.13.1, < 2.0"
    }
  }
}