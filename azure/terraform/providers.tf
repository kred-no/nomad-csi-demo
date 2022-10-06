terraform {

  required_version = ">= 1.3.0"
  
  required_providers {

    azuread = {
      source = "hashicorp/azuread"
      version = ">= 2.29.0"
    }
    
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.35.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}
