terraform {
  required_version = ">= 1.8.0, < 2"
  required_providers {
    azurerm = {
      version = "~> 4"
      source  = "hashicorp/azurerm"
    }
    azuread = {
      version = "2.50.0"
      source  = "hashicorp/azuread"
    }
    local = {
      version = "2.5.1"
      source  = "hashicorp/local"
    }
    random = {
      version = "3.6.2"
      source  = "hashicorp/random"
    }
  }
  backend "azurerm" {}
}