
resource "kubernetes_namespace" "ingress" {  
  metadata {
    name = "nginx-ingress"
  }
}

# Install ingress helm chart using terraform
resource "helm_release" "ingress" {
  name       = "ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.5.2"
  namespace  = kubernetes_namespace.ingress.metadata.0.name
  values = [
    file("ingress-controller/nginx-controller.yaml")
  ]
  depends_on = [
    kubernetes_namespace.ingress
  ]
}
