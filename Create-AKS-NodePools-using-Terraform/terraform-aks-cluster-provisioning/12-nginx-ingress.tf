

data "terraform_remote_state" "aks" {
  depends_on = [
    azurerm_kubernetes_cluster.aks_cluster
  ]
  backend = "azurerm"

    config = {
    resource_group_name   = "terraform-rg"
    storage_account_name  = "terraformstatepoc2"
    container_name        = "tfstatefiles"
    key                   = "dev.terraform.tfstate"
  }
}

data "azurerm_kubernetes_cluster" "cluster" {
  name                = data.terraform_remote_state.aks.outputs.aks_cluster_name
  resource_group_name = data.terraform_remote_state.aks.outputs.resource_group_name
}

#https://github.com/learnk8s/terraform-aks/blob/master/03-aks-helm/main.tf
provider "kubernetes" {
  
    host = data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.host

    client_key             = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.client_key)
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.client_certificate)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host = data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.host

    client_key             = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.client_key)
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.client_certificate)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.cluster_ca_certificate)
  }
}

provider "kubectl" {
  host                   = data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.cluster.kube_admin_config.0.cluster_ca_certificate)
}

resource "kubernetes_namespace" "ingress_nginx" {  
  depends_on = [
    data.azurerm_kubernetes_cluster.cluster
  ]
  metadata {
    name = "ingress-nginx"
  }
}

# Install ingress helm chart using terraform
resource "helm_release" "ingress" {
  name       = "ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.5.2"
  namespace  = kubernetes_namespace.ingress_nginx.metadata.0.name
  values = [
    file("ingress-controller/nginx-controller.yaml")
  ]
  depends_on = [
    kubernetes_namespace.ingress_nginx
  ]
}
