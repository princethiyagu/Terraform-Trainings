#inside rdp on desktop create a directory called as tf-project
  #then open visual studio code#
  #click on file from the drop down enable autosave option
  #then click on file again open folder select desktop and select the folder tfproject 
  ##in visual studio code near your tfstate folder name there is an + icon if you click on the same it will create a file give the name as resource.tf
  #inside resource.tf we will define our resource group copy from line 7 till 10 and paste it inside reosurce.tf file  change my name to your name
  resource "azurerm_resource_group" "my_rg" {
  name     = "gopal-rg"
  location = "eastus"
}

##then at the top click on ... you will see terminal new terminale 
  terraform init
  ######################
  terraform validate
  ###finally lets plan it
  terraform plan
  ##check the error 
##if you are geetting provider error
##create file provider.tf copy line number 21 till 33
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=5.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

#then again do
terraform init
terraform validate
terraform plan
