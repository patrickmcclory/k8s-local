#!/bin/bash
rsync -uav --chmod=+r --exclude='.git' . 172.16.16.3:/opt/k8s-local

dl-client 1 off
dl-client 2 off
dl-client 3 off
dl-client 4 off
dl-client 5 off
dl-client 6 off
dl-client 7 off

# dev-01 - master
#dl-client 6 off
dl-client 6 on

# dev-02 - minion
# dl-client 1 ccl

# dev-05 - minion
# dl-client 3 ccl

# dev-06 - minion
# dl-client 7 ccl

# dev-07 - minion
# dl-client 4 ccl

ssh pmdev@172.16.16.3 'sudo tail -f /var/log/syslog /var/log/nginx/access.log'
