terraform {
  required_version = ">= 1.8.0, < 2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4"
    }
    azuread = {
      version = "3.8.0"
      source  = "hashicorp/azuread"
    }
    local = {
      version = "2.8.0"
      source  = "hashicorp/local"
    }
    random = {
      version = "3.8.1"
      source  = "hashicorp/random"
    }
  }
  backend "azurerm" {}
}