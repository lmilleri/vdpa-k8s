ip netns exec sriov-worker ip link set ens1f0np0 netns 1
vdpa dev add name vdpa:0000:65:00.2 mgmt pci/0000:65:00.2
vdpa dev add name vdpa:0000:65:00.3 mgmt pci/0000:65:00.3
ip link set ens1f0np0 netns sriov-worker
