echo "POD711:"
oc exec -it -n vdpa vdpa-pod711 -- env | grep vhost-vdpa
echo "POD712:"
oc exec -it -n vdpa vdpa-pod712 -- env | grep vhost-vdpa
oc exec -it -n openshift-ovn-kubernetes `./find-ovnkube-node-711.sh | awk 'FNR == 2 {print $1}'` -c ovnkube-controller -- /usr/bin/ovn-nbctl show l2.network_ovn_localnet_switch
