#!/usr/bin/env bash

#./uninstall-sriov-plugin.sh 

if [[ $# -eq 1 ]] ; then
        vdpa=$1
        if [[ $vdpa != "vdpa" ]] ; then
        	echo $vdpa "mode not supported"
	        exit -1
	else
        	echo "VDPA mode"
	fi
fi

if [[ $vdpa != "" ]] ; then
	./uninstall-configmap-vdpa.sh
else 
	./uninstall-configmap.sh
fi

#./uninstall-flannel.sh 
./uninstall-ovn.sh
./uninstall-ovs.sh
./uninstall-multus.sh 
./reset-cluster.sh
./delete-vfs.sh
#./uninstall-k8s.sh
#./uninstall-crio.sh

sudo rm -f /etc/sriov_config.json
sudo systemctl stop switchdev-configuration-before-nm.service
sudo systemctl disable switchdev-configuration-before-nm.service
sudo systemctl stop switchdev-configuration-after-nm.service
sudo systemctl disable switchdev-configuration-after-nm.service
