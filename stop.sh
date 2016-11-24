#!/bin/bash
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

dl-client 1 off
dl-client 2 off
dl-client 3 off
dl-client 4 off
dl-client 5 off
dl-client 6 off
dl-client 7 off

echo ''
echo '*******************************************************************************'
echo 'k8s-local shutdown sequence complete'
echo '*******************************************************************************'
