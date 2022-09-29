#!/usr/bin/env bash
nic0_mode=$(sudo devlink dev eswitch show pci/0000:65:00.0)
nic0_current=$(sudo cat /sys/class/net/ens1f0np0/device/sriov_numvfs)
nic0_total=$(sudo cat /sys/class/net/ens1f0np0/device/sriov_totalvfs)
sudo echo $nic0_mode
sudo echo "0000:65:00.0 current-vfs :" $nic0_current
sudo echo "0000:65:00.0 total-vfs :" $nic0_total

echo ""

nic1_mode=$(sudo devlink dev eswitch show pci/0000:65:00.1)
nic1_current=$(sudo cat /sys/class/net/ens1f1np1/device/sriov_numvfs)
nic1_total=$(sudo cat /sys/class/net/ens1f1np1/device/sriov_totalvfs)
sudo echo $nic1_mode
sudo echo "0000:65:00.1 current-vfs :" $nic1_current
sudo echo "0000:65:00.1 total-vfs :" $nic1_total
