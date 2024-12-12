terraform {
  required_version = ">= 1.2.0"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.68.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.39.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
  }
}