resource "kubernetes_namespace" "project2-pvc-routing" {  
  metadata {
    name = "project2-ns"
  }
}

resource "null_resource" "deploy-components" {
  depends_on = [kubernetes_namespace.project2-pvc-routing]
  provisioner "local-exec" {
      command = "kubectl apply -f kube-manifests/  --namespace project2-ns --recursive"
  }

  provisioner "local-exec" {
      when    = destroy
      command = "kubectl delete -f kube-manifests/  --namespace project2-ns --recursive"
  }
}

