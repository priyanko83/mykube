resource "null_resource" "deploy-yaml" {
  depends_on = [
    helm_release.application
  ]
  provisioner "local-exec" {
      command = "kubectl apply -f demo-route-app/  --namespace project1-namespace --recursive"
  }
}