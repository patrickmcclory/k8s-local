# k8s-local
... a poor attempt at trying to figure out Kubernetes on my bare metal lab.

## Deployment Options

Per the CoreOS documentation, I'm using the following variable values for my cluster:

```bash
MASTER_HOST=172.16.16.10
ETCD_ENDPOINTS=http://172.16.16.10:2379
POD_NETWORK=10.2.0.0/16
SERVICE_IP_RANGE=10.3.0.0/24
K8S_SERVICE_IP=10.3.0.1
DNS_SERVICE_IP=10.3.0.10
```
