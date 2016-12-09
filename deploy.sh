#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

while (( $(kubectl get nodes | wc -l) < 4 )); do
  echo 'Waiting for Kubernetes to become available';
  sleep 10;
done;

kubectl create -f "${DIR}/deploy/kube-dns-addon.yaml"
kubectl create -f "${DIR}/deploy/kubernetes-dashboard.yaml"

echo "********************************************************************************"
echo "*"
echo "* Done Deploying assets into Kubernetes"
echo "*"
echo "********************************************************************************"
