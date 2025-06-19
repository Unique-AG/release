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
  }
}