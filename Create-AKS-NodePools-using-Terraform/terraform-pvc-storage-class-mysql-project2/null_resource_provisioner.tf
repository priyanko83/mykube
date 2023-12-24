resource "null_resource" "deploy-namespace" {
  provisioner "local-exec" {
      command = "kubectl apply -f namespace.yaml"
  }

  provisioner "local-exec" {
      when    = destroy
      command = "kubectl delete -f namespace.yaml"
  }
}

resource "null_resource" "deploy-components" {
  depends_on = [null_resource.deploy-namespace]
  provisioner "local-exec" {
      command = "kubectl apply -f kube-manifests/  --namespace project2-ns --recursive"
  }

  provisioner "local-exec" {
      when    = destroy
      command = "kubectl delete -f kube-manifests/  --namespace project2-ns --recursive"
  }
}
