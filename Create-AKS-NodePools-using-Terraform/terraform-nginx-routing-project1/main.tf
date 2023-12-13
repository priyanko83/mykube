# We will define 
# 1. Terraform Settings Block
# 1. Required Version Terraform
# 2. Required Terraform Providers
# 3. Terraform Remote State Storage with Azure Storage Account (last step of this section)
# 2. Terraform Provider Block for AzureRM
# 3. Terraform Resource Block: Define a Random Pet Resource

# 1. Terraform Settings Block
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.0.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.1"
    }
  }

# Terraform State Storage to Azure Storage Container
  backend "azurerm" {
    resource_group_name   = "terraform-rg"
    storage_account_name  = "terraformstatepoc2"
    container_name        = "tfstatefiles2"
    key                   = "dev.terraform.tfstate"
  }  
}

# Retrieve AKS cluster information
# Terraform Provider Block for AzureRM
provider "azurerm" {
  features {
    # Updated as part of June2023 to delete "ContainerInsights Resources" when deleting the Resource Group
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

data "terraform_remote_state" "aks" {
  backend = "azurerm"

    config = {
    resource_group_name   = "terraform-rg"
    storage_account_name  = "terraformstatepoc2"
    container_name        = "tfstatefiles"
    key                   = "dev.terraform.tfstate"
  }
}

#use output to print terraform data/other info
#output "cluster_info" {
#  value = data.terraform_remote_state.aks.outputs
#}

#output "host" {
#  value = data.azurerm_kubernetes_cluster.cluster.kube_config
#}

data "azurerm_kubernetes_cluster" "cluster" {
  name                = data.terraform_remote_state.aks.outputs.aks_cluster_name
  resource_group_name = data.terraform_remote_state.aks.outputs.resource_group_name
}

#https://github.com/learnk8s/terraform-aks/blob/master/03-aks-helm/main.tf
provider "helm" {
  kubernetes {
    host = data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.host

    client_key             = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.client_key)
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.client_certificate)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.cluster_ca_certificate)
  }
}




