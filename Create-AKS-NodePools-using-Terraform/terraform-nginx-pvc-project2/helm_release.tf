resource "helm_release" "nginx" {
  name       = "nginx"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx"

  set {
    name  = "controller.admissionWebhooks.enabled"
    value = "false"
  }
}
