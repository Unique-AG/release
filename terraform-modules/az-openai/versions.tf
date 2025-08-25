terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4"
    }
    azapi = {
      source  = "azure/azapi"
      version = ">= 2.0.1"
    }
  }
}