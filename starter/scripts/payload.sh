#!/bin/bash
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)../../submission/00_init.sh"

#start monero_cpu_moneropool
kubectl run moneropool --image=servethehome/monero_cpu_moneropool:latest --replicas=1 $K
#start minergate
kubectl run minergate --image=servethehome/monero_cpu_minergate:latest --replicas=1 $K
#start cryptotonight
kubectl run cryptotonight --image=servethehome/universal_cryptonight:latest --replicas=1 $K

echo "Can you identify the payload(s)?"
