#!/bin/bash

export MASTER_HOST=172.16.16.10
export ETCD_ENDPOINTS=http://172.16.16.10:2379
export POD_NETWORK=10.2.0.0/16
export SERVICE_IP_RANGE=10.3.0.0/24
export K8S_SERVICE_IP=10.3.0.1
export DNS_SERVICE_IP=10.3.0.10

export CLUSTER_DOMAIN_NAME=lab.mcclory.io
export K8S_VERSION=v1.4.5

# remote host setup variables
export NUMBER_OF_HOSTS=7
export REMOTE_MACHINE_USER=pmdev
export REMOTE_MACHINE_ADDRESS=172.16.16.3

# Power strip port id for automated power handling
export MASTER_NODE_POWER_ID=6
export MINION_NODE_POWER_IDS=(1 2 3 4 5 7)
export ALL_POWER_IDS=(1 2 3 4 5 6 7)

# kubectl config values...
export KUBECTL_CLUSTER_NAME=default-cluster
export KUBECTL_CREDENTIAL_NAME=default-admin
export KUBECTL_CONTEXT_NAME=default-system
