#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source ${DIR}/variables.sh

CA_CERT=${DIR}/keys/ca.pem
ADMIN_KEY=${DIR}/keys/admin-key.pem
ADMIN_CERT=${DIR}/keys/admin.pem

if [ ! -f /usr/local/bin/kubectl ]; then
  echo "Downloading kubectl for k8s version [${K8S_VERSION}]"
  sudo wget https://storage.googleapis.com/kubernetes-release/release/${K8S_VERSION}/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl
fi

sudo chmod +x /usr/local/bin/kubectl

if [ -f ~/.kube/config ]; then
  echo "Kubectl config exists... just a heads up that we'll overwrite some or all of it here... "
fi

echo "Setting up kubectl configuration for ${KUBECTL_CLUSTER_NAME} cluster at ${MASTER_HOST}"

echo "Deleting ${KUBECTL_CONTEXT_NAME} context and cluster if it exists"
kubectl config delete-context ${KUBECTL_CONTEXT_NAME}
kubectl config delete-cluster ${KUBECTL_CLUSTER_NAME}

kubectl config set-cluster ${KUBECTL_CLUSTER_NAME} --server=https://${MASTER_HOST} --certificate-authority=${CA_CERT}
kubectl config set-credentials ${KUBECTL_CREDENTIAL_NAME} --certificate-authority=${CA_CERT} --client-key=${ADMIN_KEY} --client-certificate=${ADMIN_CERT}
kubectl config set-context ${KUBECTL_CONTEXT_NAME} --cluster=${KUBECTL_CLUSTER_NAME} --user=${KUBECTL_CREDENTIAL_NAME}
kubectl config use-context ${KUBECTL_CONTEXT_NAME}
