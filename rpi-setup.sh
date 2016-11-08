#!/bin/bash

# Variables set per https://coreos.com/kubernetes/docs/latest/openssl.html
MASTER_HOST=172.16.16.10
K8S_SERVICE_IP=10.3.0.1
CLUSTER_DOMAIN_NAME=lab.mcclory.io
NUMBER_OF_HOSTS=7

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo ""
echo "Set up dnsmasq and configure for use"
echo ""
if [ $(dpkg-query -W -f='${Status}' nginx 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "  Installing DNSMASQ"
  sudo apt-get install -y nginx;
else
  echo "  DNSMASQ is already installed."
fi

sudo sed -i "/DNSMASQ_OPTS=/c\DNSMASQ_OPTS=--conf-file=$DIR\/dnsmasq\/dnsmasq.conf" /etc/default/dnsmasq

echo "  DNSMASQ reconfigured"

sudo service dnsmasq restart
echo ""


if [ -d /var/lib/tftpboot/pxelinux.cfg ];
then
  sudo rm -rf /var/lib/tftpboot/pxelinux.cfg
  echo "Removed old /var/lib/tftpboot/pxelinux.cfg"
fi

# setting up tftp boot folder
sudo mkdir -p /var/lib/tftpboot/

echo ''
echo 'Getting CoreOS files for alpha, beta and stable releases... just in case'
echo ''

sudo mkdir -p /var/lib/tftpboot/coreos/alpha
sudo mkdir -p /var/lib/tftpboot/coreos/beta
sudo mkdir -p /var/lib/tftpboot/coreos/stable

for releasename in alpha beta stable; do
  echo "    Downloading $releasename files"
  sudo mkdir -p /var/lib/tftpboot/coreos/$releasename
  sudo curl https://$releasename.release.core-os.net/amd64-usr/current/coreos_production_pxe.vmlinuz -o /var/lib/tftpboot/coreos/$releasename/coreos_production_pxe.vmlinuz
  sudo curl https://$releasename.release.core-os.net/amd64-usr/current/coreos_production_pxe_image.cpio.gz -o /var/lib/tftpboot/coreos/$releasename/coreos_production_pxe_image.cpio.gz
done

sudo chmod -R 755 /var/lib/tftpboot/*

echo ""
echo "Done getting CoreOS files!"

echo ''
echo 'Getting core pxeboot files for pxeboot process'
echo ''

filelist=("gpxelinux.0" "ldlinux.c32" "lpxelinux.0" "memdisk" "menu.c32" "pxelinux.0")

for filename in "${filelist[@]}"; do
  sudo rm -rf /var/lib/tftpboot/$filename
  sudo curl http://www.mcclory.io/resources/pxeboot/$filename -o /var/lib/tftpboot/$filename
done

echo ''
echo 'Symlinking pxelinux.cfg from repository'
echo ''

sudo ln -s $DIR/tftpboot/pxelinux.cfg /var/lib/tftpboot/

sudo chmod -R 755 /var/lib/tftpboot/*


# Set up nginx and configure for use
echo ""
if [ $(dpkg-query -W -f='${Status}' nginx 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "  Installing Nginx"
  sudo apt-get install -y nginx;
else
  echo "  Nginx is already installed."
fi

if [ -f /etc/nginx/sites-enabled/default ];
then
  sudo rm -rf /etc/nginx/sites-enabled/default
  echo "  Removed default nginx from sites-enabled"
fi

echo ""
echo "  Writing nginx config file."

cat >> /tmp/pxeboot.conf << EOF
server {
	listen 80 default_server;
	listen [::]:80 default_server;
  root $DIR/http;
  server_name _;
  location / {
    try_files \$uri \$uri/ =404;
  }
}

EOF

sudo mv /tmp/pxeboot.conf /etc/nginx/sites-available/pxeboot.conf
sudo ln -s /etc/nginx/sites-available/pxeboot.conf /etc/nginx/sites-enabled/pxeboot.conf
sudo service nginx restart

echo ""
echo "Downloading k8s"

# Download k8s files
sudo mkdir -p $DIR/http/k8s/1.4.5
curl -L https://github.com/kubernetes/kubernetes/releases/download/v1.4.5/kubernetes.tar.gz -o /tmp/kuberntes.tar.gz
cd /tmp
tar xvf /tmp/kuberntes.tar.gz
sudo mv /tmp/kubernetes/server/kubernetes-server-linux-amd64.tar.gz $DIR/http/k8s/1.4.5/
sudo rm -rf /tmp/kubernetes
sudo rm -rf /tmp/kubernetes.tar.gz

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

cat >> /tmp/api-openssl.cnf << EOF
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

sudo mv /tmp/api-openssl.cnf $DIR/http/keys/api-openssl.cnf

sudo openssl genrsa -out apiserver-key.pem 2048
sudo openssl req -new -key apiserver-key.pem -out apiserver.csr -subj "/CN=kube-apiserver" -config api-openssl.cnf
sudo openssl x509 -req -in apiserver.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out apiserver.pem -days 10000 -extensions v3_req -extfile api-openssl.cnf

echo ""
echo "Creating Worker Keypairs"
echo ""

cat >> /tmp/worker-openssl.cnf << EOF
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

sudo mv /tmp/worker-openssl.cnf $DIR/http/keys/worker-openssl.cnf

for (( i=1; i<=$NUMBER_OF_HOSTS; i++ ))
do

FMT_DIGIT=$(printf "%02d" $i)

WORKER_FQDN=dev-${FMT_DIGIT}.$CLUSTER_DOMAIN_NAME
WORKER_IP=192.168.1.${i}0

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
