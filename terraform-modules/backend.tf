terraform {
  required_version = ">= 1.8.0, < 2"
  required_providers {
    azurerm = {
      version = "~> 4"
      source  = "hashicorp/azurerm"
    }
    azuread = {
      version = "3.8.0"
      source  = "hashicorp/azuread"
    }
    local = {
      version = "2.7.0"
      source  = "hashicorp/local"
    }
    random = {
      version = "3.8.1"
      source  = "hashicorp/random"
    }
  }
  backend "azurerm" {}
}