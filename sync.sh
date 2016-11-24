#!/bin/bash
rsync -uav --chmod=+r --exclude='.git' . 172.16.16.3:/opt/k8s-local

echo 'Restarting dnsmasq and nginx just in case we have changed configs.'
/usr/bin/ssh pmdev@172.16.16.3 'sudo service dnsmasq restart'
/usr/bin/ssh pmdev@172.16.16.3 'sudo service nginx restart'
echo 'Done restarting dnsmasq and nginx.'

my_dir="$(dirname "$0")"
"$my_dir/stop.sh"

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

"$my_dir/start.sh" &

ssh pmdev@172.16.16.3 'sudo tail -f /var/log/syslog /var/log/nginx/access.log'
