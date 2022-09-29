#!/usr/bin/env bash

if [[ $# -eq 1 ]] ; then
	vdpa=$1
	if [[ $vdpa != "vdpa" ]] ; then
		echo $vdpa "mode not supported"
		exit -1
	else 
		echo "VDPA mode"
		export VDPA=yes
	fi
fi

#./install-crio.sh
#./install-k8s.sh

./create-eswitch-dev.sh start ens1f0np0

./install-ovs.sh
./init-cluster.sh
./install-multus.sh 
./install-ovn.sh

if [[ $vdpa != "" ]] ; then
	./install-configmap-vdpa.sh
else
	./install-configmap.sh
fi

./install-sriov-plugin.sh 
