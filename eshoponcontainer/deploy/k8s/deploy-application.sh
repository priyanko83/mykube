#!/bin/bash

# Color theming
. <(cat ./theme.sh)


#while [ "$1" != "" ]; do
#    case $1 in
#        --hostname)                     shift
#                                        hostName=$1
#                                        ;;
#        --hostip)                       shift
#                                        hostIp=$1
#                                        ;;
#        --protocol)                     shift
#                                        protocol=$1
#                                        ;;
#        --certificate)                  shift
#                                        certificate=$1
#                                        ;;
#        --charts)                       shift
#                                        charts=$1
#                                        ;;
#       * )                              echo "Invalid param: $1"
#                                        exit 1
#    esac
#    shift
#done
sleep 20
registry="poc12378acr.azurecr.io"
eshopRegistry=${ESHOP_REGISTRY}
appPrefix="eshoplearn"
chartsFolder="./helm-simple"
defaultRegistry="poc12378acr.azurecr.io"
hostIp=$(kubectl get services --namespace ingress-nginx ingress-nginx-controller --output jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "Printing hostIp"
echo $hostIp
#hostIp="104.40.94.128"
hostName=$hostIp
protocol="http"
certificate="self-signed"
useHostName=false
deployNamespace="eshop-ns"

if [ "$certificate" == "self-signed" ]
then
    pushd ./certificates >/dev/null
    ./create-self-signed-certificate.sh
    popd >/dev/null

    echo
    echo "Deploying a development self-signed certificate"
    
    ./deploy-secrets.sh
fi

if [ "$charts" == "" ]
then
    installedCharts=$(helm list --all-namespaces -qf $appPrefix-)
    echo "Charts : $installedCharts"
    if [ "$installedCharts" != "" ]
    then
        echo "Uninstalling Helm charts..."
        helmCmd="helm delete $installedCharts --namespace $deployNamespace"
        echo "${newline} > ${genericCommandStyle}$helmCmd${defaultTextStyle}${newline}"
        eval $helmCmd
    fi
    chartList=$(ls $chartsFolder)
else
    chartList=${charts//,/ }
    for chart in $chartList
    do
        installedChart=$(helm list -qf $appPrefix-$chart)
        if [ "$installedChart" != "" ]
        then
            echo
            echo "Uninstalling chart ""$chart""..."
            helmCmd="helm delete $installedChart --namespace $deployNamespace"
            echo "${newline} > ${genericCommandStyle}$helmCmd${defaultTextStyle}${newline}"
            eval $helmCmd
        fi
    done
fi

echo
echo "Deploying Helm charts from registry \"$registry\" to \"${protocol}://$hostName\"..."
echo "---------------------"

for chart in $chartList
do
    echo
    echo "Installing chart \"$chart\"..."
    helmCmd="helm install eshoplearn-$chart \"$chartsFolder/$chart\"  --namespace $deployNamespace --set registry=$registry --set imagePullPolicy=Always --set useHostName=$useHostName --set host=$hostName --set protocol=$protocol"
    echo "${newline} > ${genericCommandStyle}$helmCmd${defaultTextStyle}${newline}"
    eval $helmCmd
done

echo
echo "Helm charts deployed!"
echo 
echo "${newline} > ${genericCommandStyle}helm list${defaultTextStyle}${newline}"
helm list

echo "Displaying Kubernetes pod status..."
echo 
echo "${newline} > ${genericCommandStyle}kubectl get pods${defaultTextStyle}${newline}"
kubectl get pods

echo "The eShop-Learn application has been deployed to \"$protocol://$hostName\" (IP: $ESHOP_LBIP)." > deployment-urls.txt
echo "" >> deployment-urls.txt
echo "You can begin exploring these services (when ready):" >> deployment-urls.txt
echo "- Centralized logging       : $protocol://$hostName/seq/#/events?autorefresh (See transient failures during startup)" >> deployment-urls.txt
echo "- General application status: $protocol://$hostName/webstatus/ (See overall service status)" >> deployment-urls.txt
echo "- Web SPA application       : $protocol://$hostName/" >> deployment-urls.txt
echo "${newline}" >> deployment-urls.txt

mv deployment-urls.txt ../../
