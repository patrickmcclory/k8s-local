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

## Other Notes

| outlet id | machine name | hardware base | memory | # nics | notes |
|-----------|--------------|---------------|--------|--------|-------|
|     1     |    dev-02    | Custom AMD-based | 16 GiB | 2 | |
|     2     |    dev-03    | Custom AMD-based | 16 GiB | 2 | |
|     3     |    dev-05    | Dell Optiplex 790 - Core i7| 32 GiB | 3 | |
|     4     |    dev-07    | Dell Optiplex 790 - Core i7| 32 GiB | 3 | |
|     5     |    dev-04    | Custom AMD-based | 16 GiB | 2 | I replaced the CMOS battery on this one. Haven't done that in a long time! |
|     6     |    dev-01    | Dell Optiplex 790 - Core i7| 8 GiB | 3 | Similar spec to other Dell's but less memory. |
|     7     |    dev-06    | Dell Optiplex 790 - Core i7| 32 GiB | 3 | |
|     8     |    pxeboot   | Chromebox-M004U | 4 GiB | 1 | This replaced the Raspberry Pi 3... rest in peace fruity ARM-based provider of computing power! |
