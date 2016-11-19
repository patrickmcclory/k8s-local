#!/bin/bash

rsync -av . pmdev@172.16.16.3:/opt/k8s-local/

# dev-01 - master
dl-client 6 off
dl-client 6 on

ssh pmdev@172.16.16.3 'sudo tail -f /var/log/syslog /var/log/nginx/access.log'
