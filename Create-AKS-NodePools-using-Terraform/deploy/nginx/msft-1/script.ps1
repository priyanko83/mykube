#part2

set REGISTRY_NAME=poc12378acr
set SOURCE_REGISTRY=registry.k8s.io
set CONTROLLER_IMAGE=ingress-nginx/controller
set CONTROLLER_TAG=v1.2.1
set PATCH_IMAGE=ingress-nginx/kube-webhook-certgen
set PATCH_TAG=v1.1.1
set DEFAULTBACKEND_IMAGE=defaultbackend-amd64
set DEFAULTBACKEND_TAG=1.5


#az acr import --name poc12378acr --source registry.k8s.io/ingress-nginx/controller:v1.2.1 --image ingress-nginx/controller:v1.2.1
#az acr import --name poc12378acr --source registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.1.1 --image ingress-nginx/kube-webhook-certgen:v1.1.1
#az acr import --name poc12378acr --source registry.k8s.io/defaultbackend-amd64:1.5 --image defaultbackend-amd64:1.5

az acr import --name ${REGISTRY_NAME} --source ${SOURCE_REGISTRY}/${CONTROLLER_IMAGE}:${CONTROLLER_TAG} --image ${CONTROLLER_IMAGE}:${CONTROLLER_TAG}
az acr import --name ${REGISTRY_NAME} --source ${SOURCE_REGISTRY}/${PATCH_IMAGE}:${PATCH_TAG} --image ${PATCH_IMAGE}:${PATCH_TAG}
az acr import --name ${REGISTRY_NAME} --source ${SOURCE_REGISTRY}/${DEFAULTBACKEND_IMAGE}:${DEFAULTBACKEND_TAG} --image ${DEFAULTBACKEND_IMAGE}:${DEFAULTBACKEND_TAG}

# Add the ingress-nginx repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Set variable for ACR location to use for pulling images
set ACR_URL=poc12378acr.azurecr.io

# Use Helm to deploy an NGINX ingress controller
helm install ingress-nginx ingress-nginx/ingress-nginx --version 4.1.3 `
    --namespace ingress-basic `
    --create-namespace `
    --set controller.replicaCount=2 `
    --set controller.nodeSelector."kubernetes\.io/os"=linux `
    --set controller.image.registry=${ACR_URL} `
    --set controller.image.image=${CONTROLLER_IMAGE} `
    --set controller.image.tag=${CONTROLLER_TAG} `
    --set controller.image.digest="" `
    --set controller.admissionWebhooks.patch.nodeSelector."kubernetes\.io/os"=linux `
    --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz `
    --set controller.admissionWebhooks.patch.image.registry=${ACR_URL} `
    --set controller.admissionWebhooks.patch.image.image=${PATCH_IMAGE} `
    --set controller.admissionWebhooks.patch.image.tag=${PATCH_TAG} `
    --set controller.admissionWebhooks.patch.image.digest="" `
    --set defaultBackend.nodeSelector."kubernetes\.io/os"=linux `
    --set defaultBackend.image.registry=${ACR_URL} `
    --set defaultBackend.image.image=${DEFAULTBACKEND_IMAGE} `
    --set defaultBackend.image.tag=${DEFAULTBACKEND_TAG} `
    --set defaultBackend.image.digest=""