#!/bin/bash

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
dl-client 6 on

# delay the start of the other nodes
echo '**** Delay starting minions for 120 sec'
echo ''
echo ''
echo ''
sleep 120
echo '**** Turning Minions on now!'

dl-client 1 on
dl-client 2 on
dl-client 3 on
dl-client 4 on
dl-client 5 on
dl-client 7 on

echo '**** Done turning on the minions!'
echo ''
echo '*******************************************************************************'
echo 'k8s-local start sequence complete'
echo '*******************************************************************************'
