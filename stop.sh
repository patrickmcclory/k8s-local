#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/variables.sh

echo '*******************************************************************************'
echo 'Running k8s-local shutdown routine'
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

for client_power_id in "${ALL_POWER_IDS[@]}"; do
  dl-client ${client_power_id} off
done

echo ''
echo '*******************************************************************************'
echo 'k8s-local shutdown sequence complete'
echo '*******************************************************************************'
