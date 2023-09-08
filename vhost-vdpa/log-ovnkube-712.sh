oc logs -f -n openshift-ovn-kubernetes `./find-ovnkube-node-712.sh | awk 'FNR == 2 {print $1}'` -c ovnkube-controller
