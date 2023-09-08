#!/usr/bin/env bash

if [ "$#" -ne 5 ]; then
    echo "usage: $0 <mac1> <ip1> <mac2> <ip2> <vhost-vdpa>"
    exit -1
fi

mac1=$1
ip1=$2
mac2=$3
ip2=$4
vhost_vdpa=$5

oc exec -it -n vdpa vdpa-pod711 -- sh -c \
  "ulimit -l unlimited ; \
   cd dpdk/build/app ; \
   ./dpdk-testpmd \
   --file-prefix=tx \
   --no-pci \
   --vdev=net_virtio_user0,path=/dev/$vhost_vdpa,mac=$mac1 \
   -- \
   --port-topology=chained  \
   -i \
   --rxq=32 --txq=32 --rxd=256 --txd=256 --nb-cores=16 \
   --txonly-multi-flow \
   --burst=64 \
   --auto-start \
   --forward-mode=txonly \
   --txpkts=1200 \
   --eth-peer=0,$mac2 \
   --tx-ip=$ip1,$ip2 \
   "
