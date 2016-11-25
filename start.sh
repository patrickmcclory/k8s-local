#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/variables.sh

echo '*******************************************************************************'
echo 'Running k8s-local startup routine'
echo '*******************************************************************************'
echo ''
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

# turn on the master node
dl-client ${MASTER_NODE_POWER_ID} on

# delay the start of the other nodes
echo '**** Delay starting minions for 120 sec'
echo ''
echo ''
echo ''
sleep 120
echo '**** Turning Minions on now!'

for client_power_id in "${MINION_NODE_POWER_IDS[@]}"; do
  dl-client ${client_power_id} on
done

echo '**** Done turning on the minions!'
echo ''
echo '*******************************************************************************'
echo 'k8s-local start sequence complete'
echo '*******************************************************************************'
