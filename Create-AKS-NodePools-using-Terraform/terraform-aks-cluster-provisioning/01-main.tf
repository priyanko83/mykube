# We will define 
# 1. Terraform Settings Block
# 1. Required Version Terraform
# 2. Required Terraform Providers
# 3. Terraform Remote State Storage with Azure Storage Account (last step of this section)
# 2. Terraform Provider Block for AzureRM
# 3. Terraform Resource Block: Define a Random Pet Resource

# 1. Terraform Settings Block
terraform {
  # 1. Required Version Terraform
  required_version = ">= 1.0"
  # 2. Required Terraform Providers  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }

# Terraform State Storage to Azure Storage Container
  backend "azurerm" {
    resource_group_name   = "terraform-rg"
    storage_account_name  = "terraformstatepoc2"
    container_name        = "tfstatefiles"
    key                   = "dev.terraform.tfstate"
  }  
}



# 2. Terraform Provider Block for AzureRM
provider "azurerm" {
  features {
    # Updated as part of June2023 to delete "ContainerInsights Resources" when deleting the Resource Group
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

# 3. Terraform Resource Block: Define a Random Pet Resource
resource "random_pet" "aksrandom" {

}

