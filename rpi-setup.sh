#!/bin/bash

# Variables set per https://coreos.com/kubernetes/docs/latest/openssl.html

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo ""
echo "Set up dnsmasq and configure for use"
echo ""
if [ $(dpkg-query -W -f='${Status}' nginx 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  echo "  Installing DNSMASQ"
  sudo apt-get install -y dnsmasq;
else
  echo "  DNSMASQ is already installed."
fi

sudo sed -i "/DNSMASQ_OPTS=/c\DNSMASQ_OPTS=--conf-file=$DIR\/dnsmasq\/dnsmasq.conf" /etc/default/dnsmasq

echo "  DNSMASQ reconfigured"

sudo service dnsmasq restart
echo ""

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

sudo mkdir -p /opt/k8s-local
sudo chown ubuntu:ubuntu /opt/k8s-local
