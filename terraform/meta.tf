terraform {
  required_version = "1.3.6"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>3.17.0"
    }
    azapi = {
      source = "Azure/azapi"
      version = "~>0.4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azapi" { }

