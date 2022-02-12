terraform {
  required_version = ">=0.12"
  
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {

  features {}
}

module "major" {
  source                                    = "./modules/major"

  name                                      = var.project.name
  location                                  = var.project.location
}

module "lb" {
  source                                    = "./modules/lb"

  name                                      = var.project.name
  rgroup                                    = module.major.rgroup
  vnet                                      = module.major.vnet
  
     

}

