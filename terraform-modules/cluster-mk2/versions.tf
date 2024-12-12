terraform {
  required_version = ">= 1.2.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.116.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.39.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }
  }
}