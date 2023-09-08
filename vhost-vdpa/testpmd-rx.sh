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

oc exec -it -n vdpa vdpa-pod712 -- sh -c \
  "ulimit -l unlimited ; \
   cd dpdk/build/app ; \
   ./dpdk-testpmd \
   --no-pci \
   --vdev=net_virtio_user0,path=/dev/$vhost_vdpa,mac=$mac2 \
   --file-prefix=virtio \
   -- \
   -i \
   --rxq=32 --txq=32 --rxd=256 --txd=256 --nb-cores=16 \
   --burst=64 \
   --auto-start \
   --forward-mode=rxonly \
   --eth-peer=0,$mac1 \
   --tx-ip=$ip2,$ip1"
