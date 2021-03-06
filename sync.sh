#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/variables.sh

rsync -uav --chmod=+r --exclude='.git' . ${REMOTE_MACHINE_USER}@${REMOTE_MACHINE_ADDRESS}:/opt/k8s-local

echo 'Restarting dnsmasq and nginx just in case we have changed configs.'
/usr/bin/ssh ${REMOTE_MACHINE_USER}@${REMOTE_MACHINE_ADDRESS} 'sudo service dnsmasq restart'
/usr/bin/ssh ${REMOTE_MACHINE_USER}@${REMOTE_MACHINE_ADDRESS} 'sudo service nginx restart'
echo 'Done restarting dnsmasq and nginx.'

#| outlet id | machine name |
#|-----------|--------------|
#|     1     |    dev-02    |
#|     2     |    dev-03    |
#|     3     |    dev-05    |
#|     4     |    dev-07    |
#|     5     |    dev-04    |
#|     6     |    dev-01    |
#|     7     |    dev-06    |
#|     8     |    pxeboot   |


bash "${DIR}/start.sh"

echo 'Waiting for Kubernetes to become available';
sleep 60

while (( $(kubectl get nodes | wc -l) < 4 )); do
  '... still waiting'
  sleep 10;
done;

echo 'Kubectl get nodes now responds with multiple nodes!'
