#!/usr/bin/env bash

#################################
# include the -=magic=-
# you can pass command line args
#
# example:
# to disable simulated typing
# . ../demo-magic.sh -d
#
# pass -h to see all options
#################################
. ./demo-magic.sh


########################
# Configure the options
########################

#
# speed at which to simulate typing. bigger num = faster
#
TYPE_SPEED=20

#
# custom prompt
#
# see http://www.tldp.org/HOWTO/Bash-Prompt-HOWTO/bash-prompt-escape-sequences.html for escape sequences
#
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"

# text color
# DEMO_CMD_COLOR=$BLACK
DEMO_CMD_COLOR=$WHITE

# hide the evidence
clear

delay_1s () {
   PROMPT_TIMEOUT=1
   wait
}


delay_sec() {
   PROMPT_TIMEOUT=$1
   wait
}

# enters interactive mode and allows newly typed command to be executed
cmd

# put your demo awesomeness here
p "Welcome to virtio/vdpa in Openshift demo!"
p "in this demo, we're going to show two containers pinging each other using vDPA interfaces"
p "for simplicity, the pods will be created on the same worker node, but nothing changes in case of inter-node communication"
delay_1s
#p ""
#p "Pre-requirements:"
#p "   Openshift cluster running on 2 bare metal servers"
#p "   virtlab712: running 3 control plane nodes as VMs"
#p "   virtlab711: running worker node on bare metal"
#p "   NVIDIA ConnectX-6 Dx (dual port) on both servers"
#p "   the 2 NICs are connected back-to-back with a cable"
#p "      virtlab712:ens1f1 ----- virtlab711:ens1f1 (cluster default network)"
#p "      virtlab712:ens1f0 ----- virtlab711:ens1f0 (NIC under test)"
#p "   SRIOV-network-operator is installed"
#delay_1s
delay_1s

p "check the state of the nodes:"
delay_1s
pei "oc get nodes"
delay_1s
delay_1s

p "check if all the pods are running properly:"
delay_1s
pei "oc get pods --all-namespaces | grep -v \"Running\" | grep -v \"Completed\""
delay_1s
delay_1s

p "create the MachineConfigPool:"
pei "cat mcp-offloading.yaml"
delay_sec 2
pei "oc create -f mcp-offloading.yaml"
delay_1s
delay_1s

p "label the worker node to be part of the pool:"
delay_1s
pei "oc label node virtlab711.virt.lab.eng.bos.redhat.com node-role.kubernetes.io/mcp-offloading=\"\""
delay_1s
delay_1s

p "label the worker node as a SRIOV capable node:"
delay_1s
pei "oc label node virtlab711.virt.lab.eng.bos.redhat.com feature.node.kubernetes.io/network-sriov.capable=true"
delay_1s
delay_1s

p "create the SRIOV network pool configuration and enable OVS HW offloading."
p "This command will reboot the worker node:"
delay_1s
pei "cat sriov-pool-config.yaml"
delay_sec 2
pei "oc create -f sriov-pool-config.yaml"
delay_1s
delay_1s

PROMPT_TIMEOUT=600
wait

p "state of the nodes after worker reboot"
delay_1s
pei "oc get nodes"
delay_1s
delay_1s

p "this is the policy for the SRIOV-network-operator:"
delay_1s
pei "cat policy.yaml"
delay_sec 2

p "let's find out which is the netdevice associated to the PCI device 0000:65:00.0:"
delay_1s
pei "ssh virtlab711 \"ls -la /sys/bus/pci/devices/0000\:65\:00.0/net\""
delay_1s
delay_1s

p "there are no VFs yet:"
delay_1s
pei "ssh virtlab711 \"ip link show ens1f0\""
delay_1s
delay_1s

# p "state of the SRIOV-network-operator before applying the policy:"
# delay_1s
# pei "oc get sriovnetworknodestates.sriovnetwork.openshift.io -n openshift-sriov-network-operator virtlab711.virt.lab.eng.bos.redhat.com -o yaml"
# delay_sec 2

p "now let's apply the policy to the sriov-network-operator, the node will reboot ..."
delay_1s
pei "oc create -f policy.yaml"

PROMPT_TIMEOUT=600
wait

p "state of the nodes after worker reboot"
delay_1s
pei "oc get nodes"
delay_1s
delay_1s

#p "check the state of the SRIOV-network-operator after the policy has been applied:"
#delay_1s
#pei "oc get sriovnetworknodestates.sriovnetwork.openshift.io -n openshift-sriov-network-operator virtlab711.virt.lab.eng.bos.redhat.com -o yaml"
#delay_sec 10

p "let's check if the VFs have been created properly:"
delay_1s
pei "ssh virtlab711 \"ip link show ens1f0\""
delay_1s
delay_1s

#p "let's check the number of VFs:"
#delay_1s
#pei "ssh virtlab711 \"cat /sys/class/net/ens1f0/device/sriov_numvfs\""
#delay_1s
#delay_1s

p "let's check the newly created vDPA devices:"
delay_1s
pei "ssh virtlab711 \"vdpa dev show\""
delay_1s
delay_1s

p "the NIC mode should be switchdev:"
delay_1s
pei "ssh virtlab711 \"sudo devlink dev eswitch show pci/0000:65:00.0\""
delay_1s
delay_1s

p "the NIC should have HW offload enabled:"
delay_1s
pei "ssh virtlab711 \"ethtool -k ens1f0 | grep hw-tc-offload\""
delay_1s
delay_1s

p "please note that all the interfaces presented below, belongs to the worker node (virtlab711)"
p "so the traffic will flow between those interfaces on the same worker node (loopback on the NIC card)"
delay_1s
delay_1s
p "eth0 and eth1 are the port representors (switchdev mode) and they are members of the OVS bridge:"
delay_1s
pei "ssh virtlab711 \"ethtool -i eth0\""
delay_sec 2
pei "ssh virtlab711 \"ethtool -i eth1\""
delay_sec 2
p "eth2 and eth3 are the virtio/vdpa interfaces that will be moved into the container namespace:"
delay_1s
pei "ssh virtlab711 \"ethtool -i eth2\""
delay_sec 2
pei "ssh virtlab711 \"ethtool -i eth3\""
delay_sec 2

# p "device info files are created under the directory /var/run/k8s.cni.cncf.io/devinfo/dp"
# p "these files contain info that is shared between kubelet and plugins in kubernetes:"
# delay_1s
# pei "ssh virtlab711 \"ls -la /var/run/k8s.cni.cncf.io/devinfo/dp\""
# delay_1s
# delay_1s
# pei "ssh virtlab711 \"cat /var/run/k8s.cni.cncf.io/devinfo/dp/openshift.io-mlxnics-0000:65:00.2-device.json | jq\""
# delay_1s
# delay_1s
# delay_1s

p "create the network attachment definition:"
delay_1s
pei "cat network-attach-a.yaml"
delay_sec 2
pei "oc create -f network-attach-a.yaml"
delay_1s
delay_1s

p "create the first pod:"
delay_1s
pei "cat vdpa-pod1.yaml"
delay_sec 2
pei "oc create -f vdpa-pod1.yaml"
delay_1s
delay_1s

p "create the second pod:"
delay_1s
pei "cat vdpa-pod2.yaml"
delay_sec 2
pei "oc create -f vdpa-pod2.yaml"
delay_1s
delay_1s

p "check the pods in the vdpa namespace:"
delay_1s
pei "oc get pods -n vdpa"
delay_1s
delay_1s

p "check first pod interface and ip address:"
delay_1s
pei "oc exec -it -n vdpa vdpa-pod1 -- ethtool -i eth0"
delay_sec 2
pei "oc exec -it -n vdpa vdpa-pod1 -- ip a"
delay_sec 5


p "check second pod interface and ip address:"
delay_1s
pei "oc exec -it -n vdpa vdpa-pod2 -- ethtool -i eth0"
delay_sec 2
pei "oc exec -it -n vdpa vdpa-pod2 -- ip a"
delay_sec 2

p "test connectivity between the pods:"

# enters interactive mode and allows newly typed command to be executed
cmd

# and reset it to manual mode to wait until user presses enter
#PROMPT_TIMEOUT=0

# run command behind
#cd .. && rm -rf stuff

# show a prompt so as not to reveal our true nature after
# the demo has concluded
delay_1s
p "We have successfully demonstrated a ping between 2 containers using a vDPA device!"
delay_1s
delay_1s
p "Thank you for watching!"
