resource "null_resource" "deploy-yaml" {
  depends_on = [
    helm_release.application
  ]
  provisioner "local-exec" {
      command = "kubectl apply -f kube-manifests/  --namespace project2pvc-namespace --recursive"
  }
}