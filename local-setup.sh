#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

MASTER_HOST=172.16.16.10
K8S_SERVICE_IP=10.3.0.1
CLUSTER_DOMAIN_NAME=lab.mcclory.io
NUMBER_OF_HOSTS=7

echo ''
echo 'Getting CoreOS files for alpha, beta and stable releases... just in case'
echo ''

for releasename in alpha beta stable; do
  echo "    Downloading $releasename files"
  sudo mkdir -p $DIR/tftpboot/coreos/$releasename
  sudo curl https://$releasename.release.core-os.net/amd64-usr/current/coreos_production_pxe.vmlinuz -o $DIR/tftpboot/coreos/$releasename/coreos_production_pxe.vmlinuz
  sudo curl https://$releasename.release.core-os.net/amd64-usr/current/coreos_production_pxe_image.cpio.gz -o $DIR/tftpboot/coreos/$releasename/coreos_production_pxe_image.cpio.gz
done

sudo chmod -R 755 /var/lib/tftpboot/*

echo ""
echo "Done getting CoreOS files!"

echo ''
echo 'Getting core pxeboot files for pxeboot process'
echo ''

filelist=("gpxelinux.0" "ldlinux.c32" "lpxelinux.0" "memdisk" "menu.c32" "pxelinux.0")
for filename in "${filelist[@]}"; do
  sudo rm -rf tftpboot/$filename
  sudo curl http://www.mcclory.io/resources/pxeboot/$filename -o $DIR/tftpboot/$filename
done

echo ""
echo "Downloading k8s"

version_ids=('v1.4.6' 'v1.4.5' 'v1.4.3')
for version_id in "${version_ids[@]}"; do
  # Download k8s files
  echo "  Getting version $version_id archive"
  sudo mkdir -p $DIR/http/k8s/$version_id
  wget https://github.com/kubernetes/kubernetes/releases/download/$version_id/kubernetes.tar.gz -O /tmp/kuberntes.tar.gz
  cd /tmp
  tar xvf /tmp/kuberntes.tar.gz
  sudo mv /tmp/kubernetes/server/kubernetes-server-linux-amd64.tar.gz $DIR/http/k8s/$version_id/
  sudo rm -rf /tmp/kubernetes
  sudo rm -rf /tmp/kubernetes.tar.gz
done

echo ""
echo "Done Downloading k8s"
echo ""

# Create us some keys!
# Basically following steps here: https://coreos.com/kubernetes/docs/latest/openssl.html

cd $DIR/http/keys

echo ""
echo "Creating Clicster Root CA"
echo ""

sudo openssl genrsa -out ca-key.pem 2048
sudo openssl req -x509 -new -nodes -key ca-key.pem -days 10000 -out ca.pem -subj "/CN=kube-ca"

echo ""
echo "Creating API Server Keypair"
echo ""

cat >> api-openssl.cnf << EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster.local
DNS.5 = ${CLUSTER_DOMAIN_NAME}
IP.1 = ${K8S_SERVICE_IP}
IP.2 = ${MASTER_HOST}

EOF

sudo openssl genrsa -out apiserver-key.pem 2048
sudo openssl req -new -key apiserver-key.pem -out apiserver.csr -subj "/CN=kube-apiserver" -config api-openssl.cnf
sudo openssl x509 -req -in apiserver.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out apiserver.pem -days 10000 -extensions v3_req -extfile api-openssl.cnf

echo ""
echo "Creating Worker Keypairs"
echo ""

cat >> worker-openssl.cnf << EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
IP.1 = \$ENV::WORKER_IP

EOF

for (( i=1; i<=$NUMBER_OF_HOSTS; i++ ))
do

FMT_DIGIT=$(printf "%02d" $i)

WORKER_FQDN=dev-${FMT_DIGIT}.$CLUSTER_DOMAIN_NAME
WORKER_IP=172.16.16.${i}0

echo "FQDN: "$WORKER_FQDN
echo "IP:   "$WORKER_IP
echo ""

sudo openssl genrsa -out ${WORKER_FQDN}-worker-key.pem 2048
sudo WORKER_IP=${WORKER_IP} openssl req -new -key ${WORKER_FQDN}-worker-key.pem -out ${WORKER_FQDN}-worker.csr -subj "/CN=${WORKER_FQDN}" -config worker-openssl.cnf
sudo WORKER_IP=${WORKER_IP} openssl x509 -req -in ${WORKER_FQDN}-worker.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out ${WORKER_FQDN}-worker.pem -days 10000 -extensions v3_req -extfile worker-openssl.cnf

echo ""
echo "done!"
echo ""
echo ""
done
echo "--------------------------------------------------------------------------------"

sudo chmod 600 $DIR/http/keys/*

cd $DIRs

echo "Set up folders on Raspberry Pi"

ssh ubuntu@172.16.16.3 'sudo mkdir -p /opt/k8s-local && sudo chown -R ubuntu:ubuntu /opt/k8s-local'
